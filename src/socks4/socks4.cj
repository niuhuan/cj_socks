package cj_socks.socks4

import std.socket.*
import std.net.*
import std.io.*
import std.collection.*
import std.convert.*
import std.time.*

public class Socks4SocketFactory {
    public var host: String
    public var port: UInt16
    public var userId: Option<String>

    public init(host: String, port: UInt16, userId: Option<String>) {
        this.host = host
        this.port = port
        this.userId = userId
    }

    public init(host: String, port: UInt16) {
        this(host, port, None)
    }

    public func connect(socketAddress: IPSocketAddress): StreamingSocket {
        let socket = TcpSocket(this.host, this.port)
        try {
            socket.connect()
        } catch (e: Exception) {
            socket.close()
            throw e
        }
        return Socks4Socket(
                socket,
                socketAddress,
                userId: userId
            )
    }
}


public class Socks4Socket <: StreamingSocket {

    private let socket: StreamingSocket
    
    public mut prop readTimeout: ?Duration {
        get() { socket.readTimeout }
        set(value) { socket.readTimeout = value }
    }

    public mut prop writeTimeout: ?Duration {
        get() { socket.writeTimeout }
        set(value) { socket.writeTimeout = value }
    }

    public prop localAddress: SocketAddress {
        get() { socket.localAddress }
    }

    public prop remoteAddress: SocketAddress {
        get() { socket.remoteAddress }
    }
    
    public init(socket: StreamingSocket, socketAddress: IPSocketAddress, userId!: Option<String> = None) {
        if (!socketAddress.isIPv4()) {
            throw IllegalArgumentException("ip v4 supported only")
        }
        this.socket = socket
        try {
            socks4Connect(socketAddress, userId)
        } catch (e: Exception) {
            socket.close()
            throw e
        }
    }

    public func isClosed(): Bool {
        socket.isClosed()
    }

    public func close() {
        socket.close()
    }

    public func read(buff: Array<Byte>): Int64  {
        socket.read(buff)
    }

    public func write(buff: Array<Byte>) {
        socket.write(buff)
    }

    public func flush() {
        socket.flush()
    }
    
    public func toString(): String { 
        "Socks4Socket(${socket})"
    }

    private func socks4Connect( socketAddress: IPSocketAddress, userId: Option<String>): Unit {
        socket.write([
            0x04,  // SOCKS4
            0x01   // connect
        ])
        socket.write([
            UInt8(socketAddress.port >> 8), // port
            UInt8(socketAddress.port & 0xff) // port
        ])
        socket.write(socketAddress.address.getAddressBytes())
        if (let Some(userId) <- userId) {
            socket.write(userId.toArray())
        }
        socket.write([0x00]) // end of command
        socket.flush()
        var buff = readSize(8)
        if (buff[1] != 0x5A) {
            throw IllegalStateException("connect rejected by server")
        }
    }

    private func readSize(size: Int): Array<Byte> {
        if (size == 0) {
            return Array<Byte>(0, {_=>0})
        }
        let array = Array<Byte>(size, {_=>0})
        var read = 0
        while (true) {
            let current = socket.read(array[read..])
            if (current == 0) {
                throw IOException("eof at ${current} read")
            }
            read += current
            if (read == size) {
                break
            }
        }
        array
    }

}

