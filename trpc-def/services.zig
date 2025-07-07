const types = struct {
    pub const string = []const u8;
    pub const uuid = []const u8;

    //pub const i64 = i64;
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
