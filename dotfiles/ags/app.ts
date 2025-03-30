import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./widget/Bar"
import Calendar from "./widget/Calendar"
import Radio from "./widget/Radio"

App.start({
    css: style,
    main() {
        Bar()
        Calendar()
        Radio()
    },
})
