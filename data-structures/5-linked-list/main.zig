const std = @import("std");
const Allocator = std.mem.Allocator;

fn Node(comptime T: type) type {
    return struct {
        value: T,
        next: ?*Node(T) = null,
        prev: ?*Node(T) = null,
    };
}

fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        head: ?*Node(T) = null,
        tail: ?*Node(T) = null,
        allocator: Allocator,

        fn init(allocator: Allocator) Self {
            return Self{ .allocator = allocator };
        }

        fn deinit(self: *Self) void {
            var current = self.head;

            while (current) |node| {
                const next = node.next;
                self.allocator.destroy(node);
                current = next;
            }

            self.* = undefined;
        }

        fn append(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node(T));
            new_node.* = .{ .value = value };

            if (self.tail) |tail_node| {
                new_node.prev = tail_node;
                tail_node.next = new_node;
            } else {
                self.head = new_node;
            }

            self.tail = new_node;
        }

        fn len(self: *Self) usize {
            if (self.head == null) return 0;

            var count: usize = 0;
            var current = self.head;

            while (current) |node| {
                count += 1;
                current = node.next;
            }

            return count;
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Memory leaked!");
    }

    var linked_list = LinkedList(?usize).init(allocator);
    defer linked_list.deinit();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        try linked_list.append(10);
    }

    std.debug.print("Length: {d}\n", .{linked_list.len()});
}
