package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"net"
	"os"

	"golang.org/x/crypto/ssh"
)

func Use(v...interface{}){}

const (
    Home = "/home/tristanstille"
    SSHHostKey = Home + "/.ssh/id_rsa"

    SSHPort = 8022

    keyCtrlD     = 4
	keyCtrlU     = 21
	keyEnter     = '\r'
	keyEscape    = 27
	keyBackspace = 127
	keyUnknown   = 0xd800 /* UTF-16 surrogate area */ + iota
	keyUp
	keyDown
	keyLeft
	keyRight
	keyAltLeft
	keyAltRight
	keyAltF
	keyAltB
	keyHome
	keyEnd
	keyDeleteWord
	keyDeleteLine
	keyClearScreen
	keyPasteStart
	keyPasteEnd   
)

type EscapeCodes struct {
	// Foreground colors
	Black, Red, Green, Yellow, Blue, Magenta, Cyan, White []byte

	// Reset all attributes
	Reset []byte
}

var vt100EscapeCodes = EscapeCodes {
        Black:   []byte{keyEscape, '[', '3', '0', 'm'},
        Red:     []byte{keyEscape, '[', '3', '1', 'm'},
        Green:   []byte{keyEscape, '[', '3', '2', 'm'},
        Yellow:  []byte{keyEscape, '[', '3', '3', 'm'},
        Blue:    []byte{keyEscape, '[', '3', '4', 'm'},
        Magenta: []byte{keyEscape, '[', '3', '5', 'm'},
        Cyan:    []byte{keyEscape, '[', '3', '6', 'm'},
        White:   []byte{keyEscape, '[', '3', '7', 'm'},

        Reset: []byte{keyEscape, '[', '0', 'm'},
    }
func privateKey() ssh.Signer {

    privateBytes, err := os.ReadFile(SSHHostKey)
    if err != nil {
        log.Fatalf("Cannot load private key (%s) err (%s)", SSHHostKey, err)
    }

    privateSigner, err := ssh.ParsePrivateKey(privateBytes)
    if err != nil {
        log.Fatalf("Cannot parse private key (%s)", err)
    }

    return privateSigner
}

func main() {
    fmt.Println("Welcome to trhub")

    log.Printf("Home is: %s", Home)
    log.Printf("Private key: %s", SSHHostKey)

    sshConfig := ssh.ServerConfig {
        NoClientAuth: true,
        // Auth-related things should be constant-time to avoid timing attacks.
		PublicKeyCallback: func(conn ssh.ConnMetadata, key ssh.PublicKey) (*ssh.Permissions, error) {
			perm := &ssh.Permissions{Extensions: map[string]string{
				"pubkey": string(key.Marshal()),
			}}
			return perm, nil
		},
		KeyboardInteractiveCallback: func(conn ssh.ConnMetadata, challenge ssh.KeyboardInteractiveChallenge) (*ssh.Permissions, error) {
			return nil, nil
		},
        ServerVersion: "SSH-2.0-trhub 0.0.0",
    }

    sshConfig.AddHostKey(privateKey())


    listener, err := net.Listen("tcp", fmt.Sprintf(":%d", SSHPort))
    if err != nil {
        log.Fatalf("Impossible to listen to port %d", SSHPort)
    }

    for {

        tcpConn, err := listener.Accept()
        if err != nil {
            log.Fatalf("Cannot connect (%s)", err)
        }

        sshConn, chans, reqs, err := ssh.NewServerConn(tcpConn, &sshConfig)
        if err != nil {
            log.Printf("failed to handshake (%s)", err)
        }


        log.Printf("new connection from %s (%s)", 
            sshConn.RemoteAddr(), sshConn.ClientVersion())

        go ssh.DiscardRequests(reqs)
        go handleChannels(chans)

    }
}

func handleChannels(chans <-chan ssh.NewChannel) {
    for newChannel := range chans {

        if newChannel.ChannelType() != "session" {
            newChannel.Reject(ssh.UnknownChannelType, 
                fmt.Sprintf("unknown channel type: %s", newChannel.ChannelType()))
            continue
        }

        channel, requests, err := newChannel.Accept()
        if err != nil {
            log.Printf("could not accept channel (%s)", err)
            continue
        }


        var lock = make(chan struct{})

        go func(channel ssh.Channel, requests <-chan *ssh.Request) {
            for req := range requests {
                log.Printf("+++++ Request %s", req.Type)
                log.Printf("Request wants reply? %t", req.WantReply)
                log.Printf("Request payload %s", string(req.Payload))

                switch req.Type {
                case "shell":
                    close(lock)
                }

                if req.WantReply {
                    req.Reply(true, nil)
                }

                log.Printf("+++++ END %s", req.Type)
            }
            
        }(channel, requests)

        select {
        case <-lock:
        }

        log.Printf("Lock lifted in main")
        io.WriteString(channel, string("all setup"))
        scanner := bufio.NewScanner(channel)
        for {
            scanner.Scan()
            channel.Write([]byte("Your text> "))
            io.WriteString(channel, scanner.Text())
            channel.Write([]byte("\r\n"))
        }

    }
    
}

