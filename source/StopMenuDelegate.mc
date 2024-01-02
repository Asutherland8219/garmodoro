using Toybox.Attention as Attention;
using Toybox.System as System;
using Toybox.WatchUi as Ui;

class StopMenuDelegate extends Ui.MenuInputDelegate {
    var tickTimer = new Timer();
    var timer = new Timer();

    function initialize() {
        Ui.MenuInputDelegate.initialize();

        // Your initialization code for tickTimer and timer
    }

    function onMenuItem(item) {
        if (item == :restart) {
            play(9); // Attention.TONE_RESET
            ping(50, 1500);

            if (tickTimer != null) {
                tickTimer.stop();
            }

            if (timer != null) {
                timer.stop();
            }

            resetMinutes();
            pomodoroNumber = 1;
            isPomodoroTimerStarted = false;
            isBreakTimerStarted = false;

            if (timer != null) {
                timer.start(method(:idleCallback), 60 * 1000, true);
            }

            Ui.requestUpdate();
        } else if (item == :exit) {
            System.exit();
        }
    }
}
