const std = @import("std");
const net = std.net;
const posix = std.posix;

pub fn main() !void {
    const addr = try net.Address.parseIp("0.0.0.0", 1337);
    const socket_type = posix.SOCK.STREAM;
    const protocol = posix.IPPROTO.TCP;
    const listener = try posix.socket(addr.any.family, socket_type, protocol);
    defer posix.close(listener);

    try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(listener, &addr.any, addr.getOsSockLen());
    try posix.listen(listener, 128);
    std.debug.print("server starting...\n", .{});

    while (true) {
        var client_address: net.Address = undefined;
        var client_address_len: posix.socklen_t = @sizeOf(net.Address);

        const socket = posix.accept(listener, &client_address.any, &client_address_len, 0) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            continue;
        };

        const thread = try std.Thread.spawn(.{}, run, .{ socket, client_address });
        thread.detach();
    }
}

fn write(socket: posix.socket_t, msg: []const u8) !void {
    var pos: usize = 0;
    while (pos < msg.len) {
        const written = try posix.write(socket, msg[pos..]);
        if (written == 0) {
            return error.Closed;
        }
        pos += written;
    }
}

fn run(socket: posix.socket_t, addr: std.net.Address) !void {
    defer posix.close(socket);
    var buf: [1024]u8 = undefined;
    std.debug.print("{} connected\n", .{addr});

    const timeout = posix.timeval{ .tv_sec = 2, .tv_usec = 500_000 };
    try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.RCVTIMEO, &std.mem.toBytes(timeout));
    try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.SNDTIMEO, &std.mem.toBytes(timeout));

    const read = posix.read(socket, &buf) catch |err| {
        std.debug.print("error reading: {}\n", .{err});
        return;
    };

    if (read == 0) {
        return;
    }

    write(socket, buf[0..read]) catch |err| {
        std.debug.print("error writing: {}\n", .{err});
    };
}
