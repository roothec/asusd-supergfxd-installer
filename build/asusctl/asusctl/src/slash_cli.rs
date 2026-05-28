use argh::FromArgs;
use rog_slash::SlashMode;

#[derive(FromArgs, Debug)]
#[argh(subcommand, name = "slash", description = "slash ledbar commands")]
pub struct SlashCommand {
    #[argh(switch, description = "enable the Slash Ledbar")]
    pub enable: bool,
    #[argh(switch, description = "disable the Slash Ledbar")]
    pub disable: bool,
    #[argh(option, short = 'l', description = "set brightness value <0-255>")]
    pub brightness: Option<u8>,
    #[argh(option, description = "set interval value <0-5>")]
    pub interval: Option<u8>,
    #[argh(option, description = "set SlashMode (use 'list' for options)")]
    pub mode: Option<SlashMode>,
    #[argh(switch, description = "list available animations")]
    pub list: bool,

    #[argh(option, short = 'B', description = "show the animation on boot")]
    pub show_on_boot: Option<bool>,
    #[argh(option, short = 'S', description = "show the animation on shutdown")]
    pub show_on_shutdown: Option<bool>,
    #[argh(option, short = 's', description = "show the animation on sleep")]
    pub show_on_sleep: Option<bool>,
    #[argh(option, short = 'b', description = "show the animation on battery")]
    pub show_on_battery: Option<bool>,
    #[argh(
        option,
        short = 'w',
        description = "show the low-battery warning animation"
    )]
    pub show_battery_warning: Option<bool>,
}
