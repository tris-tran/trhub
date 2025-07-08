const types = struct {
    pub const string = []const u8;
    pub const uuid = []const u8;

    //pub const i64 = i64;
    //pub const bool = bool;
};

pub const TrpcDefCfg = struct {
    name: types.string,
    services: []const type,
};

pub const TrhubDefCfg = TrpcDefCfg{
    .name = "TRHUB",
    .services = &[_]type{
        Trhub,
    },
};

pub const Trhub = struct {
    auth: fn (token: types.string) anyerror!void,
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
    upsert: fn (user: User) anyerror!struct { failed: UserError },
    getById: fn (id: types.uuid) anyerror!struct { failed: UserError, result: User },
};

pub const User = struct {
    id: types.uuid,
    name: types.string,
};
