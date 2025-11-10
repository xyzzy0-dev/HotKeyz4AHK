#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <JSON>

; CONSTANTS
COL_DESCRIPTION := 1
COL_HOTKEY := 2
COL_TEXT := 3

; DATA
config := LoadJSONAndConfigure()
json_config_text := config.json_config_text
hotkey_map := config.hotkey_map

; GUI
mainGUI := Gui("+Resize")
mainGUI.Title := "Hotkey List"
FONT_SIZE := 8
mainGui.SetFont("s" FONT_SIZE, "Tahoma")

; HOTKEYS TITLE
mainGui.SetFont("bold s11 cNavy")
mainGUI.Add("Text", , "HOTKEYS")
mainGui.SetFont("norm s8 cDefault")

; BUTTONS
add_hk := mainGUI.Add("Button", , "Add Hotkey")
add_hk.OnEvent("Click", HandleAdd)
edit_hk := mainGUI.Add("Button", "yp", "Edit Hotkey")
edit_hk.OnEvent("Click", HandleEdit)
delete_hk := mainGUI.Add("Button", "yp", "Delete Hotkey")
delete_hk.OnEvent("Click", HandleDelete)

; HOTKEY LIST VIEW
lv_hk := mainGUI.Add("ListView", "xm w640 r10 grid -Multi", ["Description", "Hotkey", "Text"])
lv_hk.OnEvent("DoubleClick", (*) => HandleEdit(edit_hk, ""))

; POPULATE LIST VIEW AND CREATE HOTKEYS
row_count := 0
for k, v in hotkey_map["hotkeys"] {
    Hotkey(k, MakeHotKeyCallback(v["text"]))
    lv_hk.Add("", v["description"], AHKToDisplayFormat(k), v["text"])
    row_count++
}

; LV FOR HOTKEYS POSITIONING
SetupListViewColumns(lv_hk)

; HOTSTRINGS TITLE
mainGui.SetFont("bold s11 cNavy")
mainGUI.Add("Text", , "HOTSTRINGS")
mainGui.SetFont("norm s8 cDefault")

; BUTTONS
add_hs := mainGUI.Add("Button", , "Add Hotstring")
add_hs.OnEvent("Click", HandleAdd)
edit_hs := mainGUI.Add("Button", "yp", "Edit Hotstring")
edit_hs.OnEvent("Click", HandleEdit)
delete_hs := mainGUI.Add("Button", "yp", "Delete Hotstring")
delete_hs.OnEvent("Click", HandleDelete)

; LIST VIEW
lv_hs := mainGUI.Add("ListView", "xm w640 r10 grid -Multi", ["Description", "Hotstring", "Text"])
lv_hs.OnEvent("DoubleClick", (*) => HandleEdit(edit_hs, ""))

row_count := 0
for k, v in hotkey_map["hotstrings"] {
    Hotstring(k, v["text"])
    display_description := v["description"]
    display_string := SubStr(k, 4)
    lv_hs.Add("", display_description, display_string, v["text"])
    row_count++
}

; POSITIONING
SetupListViewColumns(lv_hs)

; SHOW
mainGUI.Show()

; --------------------------------------------------------------------------------
; FUNCTIONS
; --------------------------------------------------------------------------------

mainGUI.OnEvent("Close", (*) => ExitApp())

MakeHotKeyCallback(text) {
    return (*) => SendInput("{RAW}" text)
}

SetupListViewColumns(lv) {
    lv.ModifyCol(COL_DESCRIPTION, 250)  ; Desc column
    lv.ModifyCol(COL_HOTKEY, 120) ; HK column
    lv.ModifyCol(COL_TEXT, 300) ; Text column
}

AHKToDisplayFormat(ahkString) {
    ; EXTRACT BASE KEY
    baseKey := ahkString
    baseKey := StrReplace(baseKey, "^", "")
    baseKey := StrReplace(baseKey, "!", "")
    baseKey := StrReplace(baseKey, "+", "")
    baseKey := StrReplace(baseKey, "#", "")

    ; NORMALIZE: Ctrl-Alt-Shift-Win CS UI ORDER
    displayString := ""

    if InStr(ahkString, "^")
        displayString .= "Ctrl-"
    if InStr(ahkString, "!")
        displayString .= "Alt-"
    if InStr(ahkString, "+")
        displayString .= "Shift-"
    if InStr(ahkString, "#")
        displayString .= "Win-"

    displayString .= baseKey

    return displayString
}

DisplayToAHKFormat(displayString) {
    AHKString := StrReplace(displayString, "Shift-", "+")
    AHKString := StrReplace(AHKString, "Ctrl-", "^")
    AHKString := StrReplace(AHKString, "Win-", "#")
    AHKString := StrReplace(AHKString, "Alt-", "!")

    ; NORMALIZE TO AHK STANDARD ORDER: + ^ ! # (following no std principle?)
    modifiers := ""
    baseKey := AHKString

    if InStr(baseKey, "+") {
        modifiers .= "+"
        baseKey := StrReplace(baseKey, "+", "")
    }
    if InStr(baseKey, "^") {
        modifiers .= "^"
        baseKey := StrReplace(baseKey, "^", "")
    }
    if InStr(baseKey, "!") {
        modifiers .= "!"
        baseKey := StrReplace(baseKey, "!", "")
    }
    if InStr(baseKey, "#") {
        modifiers .= "#"
        baseKey := StrReplace(baseKey, "#", "")
    }

    return modifiers . baseKey
}

EditHotKeyDialog(editMode := false, hotKeyOrString := "Hotkey", rowNum := 0, oldHotkey := "", oldExpansion := "",
    oldDescription := "") {

    ; TURN OFF HOTSTRINGS AND HOTKEYS
    Suspend(1)

    ; GUI
    editDialogGui := Gui("+AlwaysOnTop +Owner" mainGUI.Hwnd, editMode ? "Edit Hotkey" : "Add Hotkey")
    mainGui.Opt("+Disabled")
    editDialogGui.OnEvent("Close", (*) => (mainGui.Opt("-Disabled"), editDialogGui.Destroy(), Suspend(0)))

    ; DESCRIPTION FIELDS
    editDialogGui.Add("Text", "w300", "Description:")
    descriptionText := editDialogGui.Add("Edit", "w300")
    if (editMode)
        descriptionText.Value := oldDescription

    ; HOTKEY/HOTSTRING FIELD
    if (hotKeyOrString == "Hotkey") {
        hotkey_txt := editDialogGui.Add("Text", "w300",
            "Click into field below, then press a key combination (like Ctrl-Q)")
        hkString := editDialogGui.Add("Hotkey", "w300")
        if (editMode) {
            hotkey_txt.Text := "Hotkey:"
            hkString.Value := oldHotkey
        }

    } else {
        editDialogGui.Add("Text", "w300", "Hotstring:")
        hkString := editDialogGui.Add("Edit", "w300")
        if (editMode)
            hkString.Value := oldHotkey
    }

    ; TEXT EXPANSION FIELD
    editDialogGui.Add("Text", "w300", "Expansion Text:")
    expansionText := editDialogGui.Add("Edit", "w300 r5")
    if (editMode)
        expansionText.Value := oldExpansion

    ; SAVE BUTTON
    okButton := editDialogGui.Add("Button", "Default w100", (hotKeyorString == "Hotkey") ? "Save Hotkey" :
        "Save Hotstring")
    okButton.OnEvent("Click", SaveHotkey)

    ; SHOW
    editDialogGui.Show()

    ; CANCEL BUTTON/FUNCTION
    editDialogGui.Add("Button", "yp w100", "Cancel").OnEvent("Click", (*) => (mainGui.Opt("-Disabled"), editDialogGui.Destroy(),
    Suspend(0)))

    ; SAVE CALLBACK FUNCTION
    SaveHotkey(GuiControl, info) {
        newDescription := Trim(descriptionText.Value)
        newTrigger := Trim(hkString.Value)
        newExpansionText := Trim(expansionText.Value)

        if (newDescription = "" || newTrigger = "" || newExpansionText = "") {
            editDialogGui.Opt("-AlwaysOnTop")
            MsgBox("All fields are required!")
            editDialogGui.Opt("+AlwaysOnTop")
            return
        }

        ; HOTKEY BRANCH
        if (InStr(GuiControl.Text, "Hotkey")) {
            this_listview := lv_hk
            this_json_key := "hotkeys"
            displayTrigger := newTrigger
            displayTrigger := AHKToDisplayFormat(displayTrigger)

            ; HOTSTRING BRANCH
        } else {
            this_listview := lv_hs
            this_json_key := "hotstrings"
            displayTrigger := newTrigger
            newTrigger := ":T:" newTrigger
        }

        ; CHECK DUPLICATES
        if (hotkey_map[this_json_key].Has(newTrigger)) {
            if (editMode) {
                ; EDIT MODE - COMPARE
                oldTriggerToCompare := (hotKeyOrString == "Hotkey") ? oldHotkey : (":T:" oldHotkey)
                if (newTrigger != oldTriggerToCompare) {
                    editDialogGui.Opt("-AlwaysOnTop")
                    MsgBox("This " hotKeyOrString " already exists!")
                    editDialogGui.Opt("+AlwaysOnTop")
                    return
                }
            } else {
                ; ADD MOVE - BLOCK ALL DUPES
                editDialogGui.Opt("-AlwaysOnTop")
                MsgBox("This " hotKeyOrString " already exists!")
                editDialogGui.Opt("+AlwaysOnTop")
                return
            }
        }

        ; CREATE NEW HOT KEY
        if (editMode) {
            if (InStr(GuiControl.Text, "Hotkey")) {
                Hotkey(oldHotkey, "Off")
                hotkey_map["hotkeys"].Delete(oldHotkey)
            } else {
                fullOldHotstring := ":T:" oldHotkey
                Hotstring(fullOldHotstring, , "Off")
                hotkey_map["hotstrings"].Delete(fullOldHotstring)
            }
        }

        ; CREATE NEW HOTSTRING
        if (InStr(GuiControl.Text, "Hotkey")) {
            Hotkey(newTrigger, MakeHotKeyCallback(newExpansionText))
            Hotkey(newTrigger, "On")
        } else {
            HotString(newTrigger, newExpansionText, "On")
        }

        ; UPDATE LISTVIEW
        if (editMode) {
            this_listview.Modify(rowNum, "", newDescription, displayTrigger, newExpansionText)
        } else {
            this_listview.Add("", newDescription, displayTrigger, newExpansionText)
        }

        ; UPDATE JSON
        hotkey_map[this_json_key][newTrigger] := Map(
            "text", newExpansionText,
            "description", newDescription
        )
        UpdateJSON(hotkey_map)

        ; ENABLE MAINGUI
        mainGui.Opt("-Disabled")

        ; TURN HOTSTRINGS BACK ON
        Suspend(0)

        ; CLOSE THE GUI
        editDialogGui.Destroy()
    }
}

HandleAdd(GuiControl, info) {
    if (InStr(GuiControl.Text, "Hotkey")) {
        EditHotKeyDialog()
    } else {
        EditHotKeyDialog(, "Hotstring")
    }
}

HandleEdit(GuiControl, info) {
    mainGUI.Opt("+OwnDialogs")
    ; EDIT HK
    if (InStr(GuiControl.Text, "Hotkey")) {
        selectedRow := lv_hk.GetNext()
        if (!selectedRow) {
            MsgBox("Please select a hotkey to edit.")
            return
        }
        hotKeyOrString := "Hotkey"
        currentDescription := lv_hk.GetText(selectedRow, 1)
        currentHotkey := lv_hk.GetText(selectedRow, 2)
        displayHotkey := DisplayToAHKFormat(currentHotkey)
        currentExpansion := lv_hk.GetText(selectedRow, 3)

        EditHotKeyDialog(true, hotKeyOrString, selectedRow, displayHotkey, currentExpansion, currentDescription)

        ; EDIT HS
    } else {
        selectedRow := lv_hs.GetNext()
        if (!selectedRow) {
            MsgBox("Please select a hotstring to edit.")
            return
        }
        hotKeyOrString := "Hotstring"
        currentDescription := lv_hs.GetText(selectedRow, 1)
        currentHotstring := lv_hs.GetText(selectedRow, 2)
        currentExpansion := lv_hs.GetText(selectedRow, 3)

        EditHotKeyDialog(true, hotKeyOrString, selectedRow, currentHotstring, currentExpansion, currentDescription)
    }
}

HandleDelete(GuiControl, info) {
    mainGUI.Opt("+OwnDialogs")
    if (InStr(GuiControl.Text, "Hotkey")) {
        selectedRow := lv_hk.GetNext()
        if (!selectedRow) {
            MsgBox("Please select a hotkey to delete.")
            return
        }

        currentDescription := lv_hk.GetText(selectedRow, 1)
        currentHotkey := lv_hk.GetText(selectedRow, 2)
        displayHotkey := DisplayToAHKFormat(currentHotkey)

        result := MsgBox("Delete hotkey '" currentDescription "' (" currentHotkey ")?", "Confirm Delete", "YesNo")
        if (result = "No")
            return

        Hotkey(displayHotkey, "Off")
        hotkey_map["hotkeys"].Delete(displayHotkey)

        lv_hk.Delete(selectedRow)

        UpdateJSON(hotkey_map)

        ; DELETE HS
    } else {
        selectedRow := lv_hs.GetNext()
        if (!selectedRow) {
            MsgBox("Please select a hotstring to delete.")
            return
        }

        currentDescription := lv_hs.GetText(selectedRow, 1)
        currentHotstring := lv_hs.GetText(selectedRow, 2)

        result := MsgBox("Delete hotstring '" currentDescription "' (" currentHotstring ")?", "Confirm Delete", "YesNo"
        )
        if (result = "No")
            return

        ; Turn off and remove the hotstring
        fullHotstring := ":T:" currentHotstring
        Hotstring(fullHotstring, , "Off")
        hotkey_map["hotstrings"].Delete(fullHotstring)

        ; Delete from listview
        lv_hs.Delete(selectedRow)

        ; Update JSON
        UpdateJSON(hotkey_map)
    }
}

LoadJSONAndConfigure() {
    try {
        json_config_text := FileOpen("config.json", "r").Read()
        hotkey_map := json_Load(&json_config_text)
        return { json_config_text: json_config_text, hotkey_map: hotkey_map }
    } catch as err {
        ; Check if config.json exists
        if FileExist("config.json") {
            ; First: Inform about corruption and need for new file
            result := MsgBox(
                "Your configuration file -- config.json -- is corrupted or invalid`n`nA new configuration file must be created to continue`n`nDo you want to proceed?",
                "Configuration File Corrupted",
                "YesNo IconX")

            if (result = "No") {
                MsgBox("Cannot continue without a configuration file", "Error", "Iconx")
                ExitApp()
            }

            ; Second: Ask about backup
            result2 := MsgBox(
                "Do you want to save a backup copy of the old configuration file in case it can be restored?",
                "Save Backup?",
                "YesNo Icon?")

            if (result2 = "Yes") {
                timestamp := FormatTime(, "yyyyMMdd_HHmmss")
                backupName := "config_corrupted_" timestamp ".json"
                try {
                    FileCopy("config.json", backupName, 1)
                    MsgBox("Backup saved as`n" backupName "`n`nCreating new config.json...", "Backup Created", "Iconi")
                } catch {
                    MsgBox("Failed to create backup`n`nContinuing with new config.json...", "Backup Failed", "IconX")
                }
            }
        } else {
            result := MsgBox("config.json not found`n`nWould you like to create a new configuration file?",
                "Configuration File Missing",
                "YesNo Icon?")

            if (result = "No") {
                MsgBox("Cannot continue without a configuration file", "Error", "Iconx")
                ExitApp()
            }
        }

        ; Create new config
        hotkey_map := Map("hotkeys", Map(), "hotstrings", Map())
        UpdateJSON(hotkey_map)
        json_config_text := json_Dump(hotkey_map, true)
        MsgBox("New config.json created successfully!", "Success", "Iconi")
        return { json_config_text: json_config_text, hotkey_map: hotkey_map }
    }
}

UpdateJSON(mapObject) {
    f_content := json_Dump(mapObject, true)
    f := FileOpen("config.json", "w")
    f.Write(f_content)
    f.Close()
}
