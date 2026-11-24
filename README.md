# ps5-discord

Share your PS5 screen on Discord from a Mac. You do not need a capture card or Remote Play, and you play on your TV as usual.

## How it works

A PS5 cannot share its screen on Discord, but it can send a broadcast to Twitch. This tool sends that broadcast to your Mac:

1. `dnsmasq` answers the DNS queries of the PS5 and points the Twitch stream servers at your Mac.
2. `mediamtx` receives the stream.
3. `PS5.app` starts `mpv`, which shows the stream in a window with the name "PS5". Discord shows only the windows of apps.

You share the "PS5" window on Discord. The stream does not go to Twitch.

This tool uses the method from [Hijacking the PS5's RTMP Stream](https://yashgarg.dev/posts/hijacking-ps5-rtmp-stream/) by Yash Garg.

## Requirements

- A Mac and a PS5 on the same network
- [Homebrew](https://brew.sh)
- The [Discord app](https://discord.com/download) (Vesktop cannot share sound on a Mac)
- A Twitch account (the PS5 shows the Twitch broadcast only after you connect an account)

## Setup

Do this procedure one time.

1. In Terminal, get the tool and start it:

   ```sh
   git clone https://github.com/ephraimduncan/ps5-discord.git
   cd ps5-discord
   ./start.sh
   ```

   The first start installs `mediamtx`, `dnsmasq`, and `mpv` with Homebrew.

2. Type your Mac password. The DNS server must have administrator permission to start.
3. Write down the IP address that the tool shows.
4. On the PS5, go to Settings > Network > Settings > Set Up Internet Connection.
5. Highlight your network.
6. Push the Options button.
7. Select Advanced Settings > DNS Settings > Manual.
8. Set Primary DNS to the IP address of your Mac.
9. Set Secondary DNS to `1.1.1.1`.
10. Go to Settings > Users and Accounts > Linked Services.
11. Connect your Twitch account.
12. In the settings of your router, reserve the IP address of your Mac. If this IP address changes, the PS5 cannot find the tool.

## Use

1. On the Mac, start the tool with `./start.sh`.
2. On the PS5, push the Create button.
3. Select Broadcast > Twitch > Go Live. The "PS5" window opens on the Mac.
4. In Discord, connect to a voice channel.
5. Click "Share Your Screen".
6. In the list of applications, select "PS5".
7. Turn on the sound.
8. Click "Go Live".
9. To stop the tool, use Ctrl+C in Terminal.

**Caution:** Start the tool before you start a broadcast. If the tool does not operate, the PS5 uses the Secondary DNS and the broadcast goes to Twitch.

## Quality

The PS5 sends a broadcast of 1920 x 1080 pixels at 60 frames per second, at most. A PS5 Pro has the same limit, and this tool cannot get a 4K picture from the PS5. To get this quality, select the highest value in Settings > Captures and Broadcasts > Broadcasts > Video Quality on the PS5.

The "PS5" window shows each pixel of the broadcast on one pixel of the screen. If you make the window smaller, the picture loses detail.

Discord sets the quality that your friends get. Without Nitro, [Discord sends 720p at 30 frames per second](https://support.discord.com/hc/en-us/articles/360040816151-Go-Live-and-Screen-Share) at most.

## Problems

| Problem | Solution |
| --- | --- |
| The "PS5" window does not open. | Make sure that the Primary DNS on the PS5 is the IP address that the tool shows. Terminal shows each host name that the PS5 looks up. Open an issue and include the lines that start with `dnsmasq`. Do not include the lines from `mediamtx`, because they show your Twitch stream key. |
| The broadcast goes to Twitch. | The PS5 used the Secondary DNS. Set the Secondary DNS to the IP address of your Mac also. Then the PS5 has an internet connection only while the tool operates. |
| Your friends cannot hear the game. | Use the Discord app, not Vesktop. Turn on the sound when you share the window. Let Discord record the screen and the system audio in System Settings > Privacy & Security. |
| You hear the game two times. | The "PS5" window plays the sound some time after the TV. Set the volume of the Mac to zero. Then make sure that your friends continue to hear the game. |
| macOS shows a prompt about incoming connections or the local network. | Click "Allow". |
| `dnsmasq` cannot make a listening socket. | A different DNS server uses port 53 on your Mac. Stop that DNS server. |

A PS5 system update can change how the PS5 sends a broadcast. Then it is possible that this tool cannot receive the broadcast.
