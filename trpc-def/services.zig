const types = struct {
    pub const string = []const u8;
    pub const uuid = []const u8;
    pub const storage = types.string;

    //pub const i64 = i64;
    //pub const bool = bool;
};

const TrpcDefCfg = struct {
    auth: type,
    storage: type,
    idempotency: bool,
    name: types.string,
    services: []type,
};

const TrhubDefCfg = TrpcDefCfg{
    .idempotency = false,
    .name = "TRHUB",
    .services = []type{
        Trhub,
    },
};

const Trhub = struct {
    auth: fn (token: type.string) void,

    userService: TrUserService,
};

const TrUserService = struct {
    upsert: fn (user: User) void,
    getById: fn (id: type.uuid) void,
};

const User = struct {
    id: type.uuid,
    name: type.string,
};
