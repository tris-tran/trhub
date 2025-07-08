const std = @import("std");
const trpcdef = @import("./trpc-def/services.zig");
const trpccmn = @import("./trpc/common/common.zig");
const trpccmndef = @import("./trpc/common/def.zig");

pub fn main() !void {
    const package = @typeInfo(trpcdef).@"struct";
    inline for (package.decls) |field| {
        std.debug.print("Package field {s}  \n ", .{field.name});
    }

    const trcfg: trpcdef.TrpcDefCfg = @field(trpcdef, "TrhubDefCfg");

    std.debug.print("Package name {s}  \n ", .{trcfg.name});

    const services = trpccmn.intrCollectService(trpcdef.Trhub, trcfg.name);

    printAllServices(services);
}

inline fn printAllServices(service: trpccmn.TrpcService) void {
    std.debug.print("Service name {s}  \n ", .{service.id});
    if (service.services) |innerServices| {
        inline for (innerServices) |innerService| {
            printAllServices(innerService);
        }
    }
}
