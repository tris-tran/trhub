const std = @import("std");

pub fn validate(comptime TRPC: type) void {
    const tInfo = @typeInfo(TRPC);

    if (tInfo != .Struct) @compileError("Expected struct");

    for (tInfo.@"struct".fields) |fInfo| {
        if (fInfo.type == .Fn) {
            const fnInfo = tInfo.@"fn";
            fnInfo.params;
            fnInfo.return_type;
        }
        if (fInfo.type == .Struct) {
            const sInfo = tInfo.@"struct";
            sInfo.fields;
        }
        @compileError("Unexpected field, not function or service");
    }
}

pub fn wtAuth(secret: []const u8) Auth {
    return .{
    };
}

const AuthProvider = struct {
};

pub fn Auth() type {
    return struct {
        auth: fn (token : []const u8) bool,

        const Self = @This();
    };
}

//This is an specialization of the TrpcType
//we want both tipes because they are the basic
//construction blocks of the rpc system
const TrpcFunction = struct {
    rType: type,
    name: []const u8,

    idempotency: bool,
    auth: bool,
};

const TrpcType = struct {
    rType: type,
    name: []const u8,
};

const TrpcService = struct {
    cfg: type,

    pub fn init() TrpcService {
        return TrpcService{};
    }

    pub fn deInit(self: *TrpcService) void {
        defer {
            _ = self.cfg;
        }
    }
};
