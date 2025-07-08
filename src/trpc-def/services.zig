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

pub const TrUserService = struct {
    upsert: fn (user: User) void,
    getById: fn (id: types.uuid) void,
};

pub const User = struct {
    id: types.uuid,
    name: types.string,
};
