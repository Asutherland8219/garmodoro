using Toybox.Attention as Attention;
using Toybox.System as System;
using Toybox.WatchUi as Ui;

class StopMenuDelegate extends Ui.MenuInputDelegate {
    var startTime = 0;

    function initialize() {
        Ui.MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :restart) {
            play(9);
            ping(50, 1500);

            if (tickTimer != null) {
                tickTimer.stop();
            }

            if (timer != null) {
                timer.stop();
            }

            if (startTime > 0) {
                var elapsedTime = System.getTimer() - startTime;
                logElapsedTime(elapsedTime);
            }

            startTime = System.getTimer();

            resetMinutes();
            pomodoroNumber = 1;
            isPomodoroTimerStarted = false;
            isBreakTimerStarted = false;

            if (timer != null) {
                timer.start(method(:idleCallback), 60 * 1000, true);
            }

            Ui.requestUpdate();
        } else if (item == :exit) {
            if (startTime > 0) {
                var elapsedTime = System.getTimer() - startTime;
                logElapsedTime(elapsedTime);
            }

            System.exit();
        }
    }

    function logElapsedTime(elapsedTime) {
        println("Elapsed Time: " + elapsedTime + " milliseconds");
    }
}
