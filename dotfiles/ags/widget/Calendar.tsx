import { App, Astal, Gtk, Gdk, astalify } from "astal/gtk3"
import { Variable, GLib } from "astal"

const GtkCalendar = astalify(Gtk.Calendar)

export default function Calendar() {
    return <window
        name="calendar"
        className="Calendar"
        visible={false}
        anchor={Astal.WindowAnchor.RIGHT
            | Astal.WindowAnchor.TOP}
        //margin-left={40}
        application={App}>
      <GtkCalendar />
    </window>
}

