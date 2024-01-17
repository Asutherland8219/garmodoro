// Import the necessary modules
using Toybox.ActivityRecording;
using Toybox.Application as App;
using Toybox.Attention as Attention;
using Toybox.WatchUi as Ui;

var timer;
var tickTimer;
var minutes = 0;
var pomodoroNumber = 1;
var isPomodoroTimerStarted = false;
var isBreakTimerStarted = false;
var session = null; // New variable to store the recording session

function ping(dutyCycle, length) {
    if (Attention has :vibrate) {
        Attention.vibrate([new Attention.VibeProfile(dutyCycle, length)]);
    }
}

function play(tone) {
    if (Attention has :playTone && !App.getApp().getProperty("muteSounds")) {
        Attention.playTone(tone);
    }
}

function idleCallback() {
    Ui.requestUpdate();
}

function isLongBreak() {
    return (pomodoroNumber % App.getApp().getProperty("numberOfPomodorosBeforeLongBreak")) == 0;
}

function resetMinutes() {
    minutes = App.getApp().getProperty("pomodoroLength");
}

class GarmodoroDelegate extends Ui.BehaviorDelegate {
    function initialize() {
    System.print("GarmodoroDelegate initialize() start");
    Ui.BehaviorDelegate.initialize();

    // Check if timer is null and initialize only if necessary
    if (timer == null) {
        System.print("timer is null, initializing...");
        timer = new Timer.Timer();
        
        // Check if the timer is still null after initialization
        if (timer == null) {
            System.print("Error: Failed to initialize timer");
        } else {
            System.print("timer initialized successfully");
            
            // Start the timer
            timer.start(method(:idleCallback), 60 * 1000, true);
        }
    } else {
        System.print("timer is already initialized");
    }

    // Initialize tickTimer if it is null
    if (tickTimer == null) {
        System.print("tickTimer is null, initializing...");
        tickTimer = new Timer.Timer(); // Adjust this based on your actual Timer class
        
        // Check if the tickTimer is still null after initialization
        if (tickTimer == null) {
            System.print("Error: Failed to initialize tickTimer");
        } else {
            System.print("tickTimer initialized successfully");
            
            // You may want to start tickTimer here if needed
        }
    } else {
        System.print("tickTimer is already initialized");
    }

    System.print("GarmodoroDelegate initialize() end");
}



    function pomodoroCallback() {
        minutes -= 1;

        if (minutes == 0) {
            play(10); // Attention.TONE_LAP
            ping(100, 1500);
            tickTimer.stop();
            timer.stop();
            isPomodoroTimerStarted = false;
            minutes = App.getApp().getProperty(isLongBreak() ? "longBreakLength" : "shortBreakLength");

            // Stop and save the session
            if (session != null && session.isRecording()) {
                session.stop();
                session.save();
                session = null;
            }

            timer.start(method(:breakCallback), 60 * 1000, true);
            isBreakTimerStarted = true;
        }

        Ui.requestUpdate();
    }

    function breakCallback() {
        minutes -= 1;

        if (minutes == 0) {
            play(7); // Attention.TONE_INTERVAL_ALERT
            ping(100, 1500);
            timer.stop();

            isBreakTimerStarted = false;
            pomodoroNumber += 1;
            resetMinutes();
            timer.start(method(:idleCallback), 60 * 1000, true);

            // Stop and save the session
            if (session != null && session.isRecording()) {
                session.stop();
                session.save();
                session = null;
            }
        }

        Ui.requestUpdate();
    }
    
    function shouldTick() {
        return App.getApp().getProperty("tickStrength") > 0;
    }

    function tickCallback() {
        ping(App.getApp().getProperty("tickStrength"), App.getApp().getProperty("tickDuration"));
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    }

    function onNextMode() {
        return true;
    }

    function onNextPage() {
        return true;
    }

    function onKey(keyEvent) {
        return onSelect();
    }

    function onSelect() {
        if (isBreakTimerStarted || isPomodoroTimerStarted) {
            if (session != null && session.isRecording()) {
                session.stop();
                session.save();
                session = null;
            }
            
            Ui.pushView(new Rez.Menus.StopMenu(), new StopMenuDelegate(), Ui.SLIDE_UP);
            return true;
        }

        if (Toybox has :ActivityRecording) {
            if ((session == null) || (session.isRecording() == false)) {
                session = ActivityRecording.createSession({
                    :name => "Pomodoro Session",
                    :sport => Activity.SPORT_GENERIC,
                    :subSport => Activity.SUB_SPORT_GENERIC
                    // Add other options as needed
                });
                session.start();
            } else if ((session != null) && session.isRecording()) {
                session.stop();
                session.save();
                session = null;
            }
        }

        play(1); // Attention.TONE_START
        ping(75, 1500);
        timer.stop();
        resetMinutes();
        timer.start(method(:pomodoroCallback), 60 * 1000, true);
        if (me.shouldTick()) {
            tickTimer.start(method(:tickCallback), App.getApp().getProperty("tickFrequency") * 1000, true);
        }
        isPomodoroTimerStarted = true;

        Ui.requestUpdate();

        return true;
    }
}
