import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "x-notifications"

  property string displayText: "𝕏"
  property string tooltipLabel: "X notifications"

  readonly property string pluginDir: (Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/x-notifications"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() { if (!pollProc.running) pollProc.running = true }

  Process {
    id: pollProc
    command: [root.pluginDir + "/bin/x-notifications"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var out = JSON.parse(text)
          root.displayText = out.text || "𝕏"
          root.tooltipLabel = out.tooltip || "X notifications"
        } catch (e) {}
      }
    }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.displayText
    slotSize: Style.bar.statusSlot
    tooltipText: root.tooltipLabel
    onPressed: if (root.bar) root.bar.run(root.pluginDir + "/bin/x-notifications-toggle")
  }
}
