import { App, Astal, Gtk, Gdk, astalify } from "astal/gtk3"
import { Variable, GLib, bind } from "astal"
import { exec, execAsync } from "astal/process"

const radio_pipe = "/tmp/eww/radio/pipe"
let playing = Variable(false)

execAsync("bash -c '../scripts/radio_handler.sh'")

export default function Radio() {
    return <window
        name="radio"
        className="Radio"
        visible={false}
        anchor={Astal.WindowAnchor.LEFT
            | Astal.WindowAnchor.TOP}
        margin_left={75}
        margin_top={20}
        margin_bottom={20}
        application={App}>
      <box css="border-radius: 10px; padding: 40px; background: #1e1e2e;">
        <button css="background: #94e2d5; border-radius: 5px; padding: 3px 15px 3px 15px;" on_clicked={
          () => {
            if (!playing.get()) {
              exec(`bash -c 'echo "play http://jpopsuki.fm:8000/autodj.m3u" >${radio_pipe}'`)
            } else {
              exec(`bash -c 'echo "stop" >${radio_pipe}'`)
            }
            playing.set(!playing.get())
          }
        }>
          <label label={bind(playing).as(b => b ? "" : "")} css="color: #1e1e2e; font-size: 24px; font-family: CaskaydiaCove Nerd Font Mono;" />
        </button>
      </box>
    </window>
}


