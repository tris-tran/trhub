const std = @import("std");
const def = @import("def.zig");

pub fn countInStruct(comptime Struct: type, Type: std.meta.Tag(std.builtin.Type)) i32 {
    var i = 0;
    for (@typeInfo(Struct).@"struct".fields) |field| {
        if (std.meta.activeTag(@typeInfo(field.type)) == Type) {
            i += 1;
        }
    }
    return i;
}

pub fn loadRpcDef(comptime Service: type, namespace: []const u8) TrpcService {
    return intrCollectService(Service, namespace);
}

pub fn intrCollectService(comptime Service: type, namespace: []const u8) TrpcService {
    return comptime blk: {
        const tInfo = @typeInfo(Service);
        if (tInfo != .@"struct") @compileError("Expected struct");

        const sFields = tInfo.@"struct".fields;
        var trpcFuncs: [countInStruct(Service, .@"fn")]TrpcFunction = undefined;
        var trpcServices: [countInStruct(Service, .@"struct")]TrpcService = undefined;

        var serviceI = 0;
        var funcsI = 0;

        for (sFields) |fInfo| {
            const funcName = fInfo.name[0..];

            switch (@typeInfo(fInfo.type)) {
                .@"fn" => {
                    const fnType = intrCollctFn(fInfo.type);

                    trpcFuncs[funcsI] = TrpcFunction{
                        .rType = fInfo.type,
                        .id = funcName,
                        .idempotency = false,
                        .auth = false,

                        .retType = fnType.retType,
                        .paramType = fnType.params,
                    };
                    funcsI += 1;
                },
                .@"struct" => {
                    const subspace = stringifyTypeName(funcName);
                    trpcServices[serviceI] = intrCollectService(fInfo.type, subspace);
                    serviceI += 1;
                },
                else => @compileError("Cannot use any other type def"),
            }
        }
        break :blk TrpcService{
            .sType = Service,
            .namespace = namespace,
            .id = stringifyTypeName(@typeName(Service)),
            .functions = &trpcFuncs,
            .services = &trpcServices,
        };
    };
}

fn intrCollctFn(comptime Function: type) struct { retType: []TrpcType, params: []TrpcType } {
    const fInfo = @typeInfo(Function);
    if (fInfo != .@"fn") @compileError("Expected function");

    const tFn = fInfo.@"fn";
    const fRet = intrCollectReturnType(tFn.return_type);
    var fParams: [tFn.params.len]TrpcType = undefined;

    inline for (tFn.params, 0..tFn.params.len) |tParam, i| {
        if (tParam.type) |pType| {
            fParams[i] = intrCollctType(pType);
        } else {
            @compileError("Cannot use generic types in the definition");
        }
    }

    return .{
        .retType = fRet,
        .params = &fParams,
    };
}

fn intrCollectReturnType(comptime MaybeType: ?type) []TrpcType {
    if (MaybeType) |Type| {
        const tInfo = @typeInfo(Type);
        if (tInfo != .error_union) @compileError("Every function needs to return error union");

        const errorUnion = tInfo.error_union;

        if (!std.meta.eql(errorUnion.error_set, anyerror))
            @compileError("All functions should return anyerror");

        const payloadType = errorUnion.payload;
        const infoPayload = @typeInfo(payloadType);

        if (infoPayload == .@"struct") {
            const rTuple = infoPayload.@"struct";

            var rTupleTypes: [rTuple.fields.len]TrpcType = undefined;
            for (&rTupleTypes, rTuple.fields) |*rTupleType, tField| {
                rTupleType.* = intrCollctType(tField.type);
            }
            return &rTupleTypes;
        } else {
            var rTupleTypes: [1]TrpcType = undefined;
            rTupleTypes[0] = intrCollctType(payloadType);
            return &rTupleTypes;
        }
    }
    @compileError("Cannot define void return functions without error");
}

fn intrCollctType(comptime Type: type) TrpcType {
    return TrpcType{
        .rType = Type,
        .id = stringifyTypeName(@typeName(Type)),
    };
}

fn stringifyTypeName(comptimeName: []const u8) []const u8 {
    if (std.mem.lastIndexOf(u8, comptimeName, ".")) |dotIndex| {
        return comptimeName[dotIndex + 1 ..];
    } else return comptimeName;
}

//This is an specialization of the TrpcType
//we want both tipes because they are the basic
//construction blocks of the rpc system
const TrpcFunction = struct {
    rType: type,
    id: []const u8,

    idempotency: bool,
    auth: bool,

    retType: []TrpcType,
    paramType: []TrpcType,
};

const TrpcType = struct {
    rType: type,
    id: []const u8,
};

pub const TrpcService = struct {
    sType: type,
    namespace: []const u8,
    id: []const u8,

    functions: []TrpcFunction,
    services: ?[]TrpcService,
};

pub const TrpcTypeVoid = TrpcType{
    .rType = undefined,
    .id = "void",
};
