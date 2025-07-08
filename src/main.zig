const std = @import("std");
const trpcdef = @import("./trpc-def/services.zig");
const trpccmn = @import("./trpc/common/common.zig");
const trpccmndef = @import("./trpc/common/def.zig");

pub fn main() !void {
    const names = trpccmn.intrCollectService(trpcdef.Trhub);
    for (names) |name| {
        std.debug.print("FuncName {s}", .{name});
    }
}
