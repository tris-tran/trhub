const std = @import("std");
const def = @import("def.zig");

pub fn intrCollectService(comptime Service: type) [][]const u8 {
    const tInfo = @typeInfo(Service);
    if (tInfo != .Struct) @compileError("Expected struct");

    const sFields = tInfo.@"struct".fields;
    const fieldNames = [sFields.len][]const u8;

    for (sFields, 0..) |fInfo, i| {
        fieldNames[i] = fInfo.name;
        if (fInfo.type == .Fn) {
            const fnInfo = tInfo.@"fn";
            _ = fnInfo;
        }
        if (fInfo.type == .Struct) {
            const sInfo = tInfo.@"struct";
            sInfo.fields;
        }
        @compileError("Unexpected field, not function or service");
    }
}

const AuthProvider = struct {};

pub fn Auth() type {
    return struct {
        auth: fn (token: []const u8) bool,

        const Self = @This();
    };
}

//This is an specialization of the TrpcType
//we want both tipes because they are the basic
//construction blocks of the rpc system
const TrpcFunction = struct {
    rType: type,
    id: []const u8,

    idempotency: bool,
    auth: bool,
};

const TrpcType = struct {
    rType: type,
    id: []const u8,
};

const TrpcService = struct {
    cfg: def.TrpcDefConf,

    pub fn init() TrpcService {
        return TrpcService{};
    }

    pub fn deInit(self: *TrpcService) void {
        _ = self;
    }
};
