pub const types = struct {
    pub const string = []const u8;
    pub const uuid = []const u8;
    pub const storage = types.string;

    //pub const i64 = i64;
    //pub const bool = bool;
};

pub const AuthType = enum {
    token,
};

pub const StorageType = enum {
    referenced,
    server,
};

pub const TrpcDefCfg = struct {
    auth: AuthType,
    storage: StorageType,

    namespace: types.string,

    services: []type,
};
