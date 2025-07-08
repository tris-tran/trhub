const types = struct {
    pub const string = []const u8;
    pub const uuid = []const u8;
    pub const storage = types.string;

    //pub const i64 = i64;
    //pub const bool = bool;
};

pub const TrpcDefCfg = struct {
    auth: type,
    storage: type,
    idempotency: bool,
    name: types.string,
    services: []type,
};

pub const TrhubDefCfg = TrpcDefCfg{
    .idempotency = false,
    .name = "TRHUB",
    .services = []type{
        Trhub,
    },
};

pub const Trhub = struct {
    auth: fn (token: types.string) void,

    userService: TrUserService,
};

pub const UserError = union(enum) {
    NotFound,
    InvalidField: struct {
        field: types.string,
        message: types.string,
    },
};

pub const TrUserService = struct {
    upsert: fn (user: User) UserError!void,
    getById: fn (id: types.uuid) UserError!void,
};

pub const User = struct {
    id: type.uuid,
    name: type.string,
};
