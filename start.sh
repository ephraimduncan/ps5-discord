#!/bin/zsh
# Catch the PS5's Twitch broadcast on this Mac and play it in a window to share on Discord.
set -eu
cd "${0:A:h}"

if ! command -v brew >/dev/null; then
  echo "Install Homebrew from https://brew.sh. Then start this tool again."
  exit 1
fi
# Homebrew puts dnsmasq in sbin, which is not always on the PATH.
dnsmasq=$(brew --prefix)/sbin/dnsmasq
command -v mediamtx >/dev/null || brew install mediamtx
command -v ffplay >/dev/null || brew install ffmpeg
[[ -x $dnsmasq ]] || brew install dnsmasq

iface=$(route -n get default | awk '/interface:/ {print $2}')
if ! ip=$(ipconfig getifaddr "$iface"); then
  echo "This Mac has no address on your network. Connect to Wi-Fi or Ethernet and turn off your VPN. Then start this tool again."
  exit 1
fi

# The PS5 looks up these hosts and pushes plain RTMP to them.
# Leave ingest.twitch.tv alone: the PS5 reaches it over HTTPS and checks its certificate.
twitch_hosts=/contribute.live-video.net/global-contribute.live-video.net/live.twitch.tv

# dnsmasq needs root to listen on port 53, so ask for the password before anything starts.
sudo -v -p "Mac password (the DNS server must have administrator permission): "

mediamtx mediamtx.yml &
mediamtx_pid=$!

# dnsmasq ignores Ctrl+C, so the trap stops it. It drops from root to this user to let the trap do that.
# Listen only on the address the PS5 can reach. Other interfaces can have their own DNS server.
sudo "$dnsmasq" --keep-in-foreground --user="$USER" --conf-file=/dev/null --no-hosts --no-resolv \
  --listen-address="$ip" --bind-interfaces \
  --server=1.1.1.1 --server=8.8.8.8 \
  --address="$twitch_hosts/$ip" \
  --log-queries --log-facility=- &
trap 'kill $mediamtx_pid 2>/dev/null; pkill -u "$USER" -x dnsmasq' EXIT
# zsh skips the EXIT trap when a signal kills it. HUP comes when the Terminal window closes.
trap 'exit 130' INT TERM HUP

cat <<EOF

On the PS5, set Primary DNS to $ip and Secondary DNS to 1.1.1.1.
Then start a Twitch broadcast. A window with the name "PS5" opens on this Mac.
To stop, use Ctrl+C.

EOF
wait $!
