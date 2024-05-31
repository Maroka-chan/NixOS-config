const hyprland = await Service.import('hyprland')

//App.resetCss();

const date = Variable('', {
    poll: [1000, 'date'],
})

const focusedTitle = Widget.Label({
    label: hyprland.active.client.bind('title'),
    visible: hyprland.active.client.bind('address')
        .as(addr => !!addr),
})

const dispatch = ws => hyprland.messageAsync(`dispatch workspace ${ws}`);

const Workspaces = () => Widget.EventBox({
    onScrollUp: () => dispatch('+1'),
    onScrollDown: () => dispatch('-1'),
    child: Widget.CenterBox({
      vertical: true,
      centerWidget: Widget.Box({
        vertical: true,
        children: Array.from({ length: 10 }, (_, i) => i + 1).map(i => Widget.Button({
          //attribute: i,
          //label: `${i}`,
          onClicked: () => dispatch(i),
          child: Widget.Label(`${i}`),
          //hexpand: false,
        })),
      }),
    }),
})

const Bar = () => Widget.Window({
    name: 'bar',
    exclusivity: 'exclusive',
    anchor: ['left', 'top', 'bottom'],
    child: Workspaces()
})

App.config({
    style: "./style.css",
    windows: [
        Bar()
    ]
})
