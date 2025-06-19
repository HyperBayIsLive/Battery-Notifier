Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Lightweight battery notifier - basic monitor
$g1 = $false
$d1 = $false
$t1 = Get-Date
$f1 = $null
$s1 = $false

function pB {
    $x1 = [System.Windows.Forms.SystemInformation]::PowerStatus
    $p1 = [math]::Round($x1.BatteryLifePercent * 100)
    $b1 = $x1.PowerLineStatus
    return @{ Percent = $p1; Status = $b1 }
}

function yZ {
    if ($s1) { return }
    $s1 = $true

    $u = New-Object System.Windows.Forms.Form
    $u.Text = "Battery Notice"
    $u.Size = New-Object System.Drawing.Size(300, 150)
    $u.StartPosition = "CenterScreen"
    $u.FormBorderStyle = "FixedDialog"
    $u.TopMost = $true
    $u.MaximizeBox = $false
    $u.MinimizeBox = $false
    $u.BackColor = [System.Drawing.Color]::White

    $l = New-Object System.Windows.Forms.Label
    $l.Text = "Battery is full. Please unplug the charger."
    $l.Size = New-Object System.Drawing.Size(260, 60)
    $l.Location = New-Object System.Drawing.Point(20, 20)
    $l.Font = New-Object System.Drawing.Font("Segoe UI", 10)

    $z = New-Object System.Windows.Forms.Button
    $z.Text = "OK"
    $z.Location = New-Object System.Drawing.Point(190, 85)
    $z.Size = New-Object System.Drawing.Size(75, 25)
    $z.Add_Click({
        $t1 = Get-Date
        $s1 = $false
        $u.Close()
    })

    $u.Controls.Add($l)
    $u.Controls.Add($z)

    $u.Add_FormClosing({
        $s1 = $false
        $t1 = Get-Date
    })

    $u.ShowDialog() | Out-Null
    $u.Dispose()
}

function zR {
    $m = New-Object System.Windows.Forms.Timer
    $m.Interval = 5000
    $m.Add_Tick({
        try {
            $d = pB
            $c = $d.Percent
            $a = $d.Status

            if ($a -eq "Online" -and $c -ge 100 -and -not $g1 -and -not $s1) {
                $diff = (Get-Date) - $t1
                if ($diff.TotalMinutes -ge 5 -or $t1 -eq (Get-Date).Date) {
                    yZ
                }
            }
        } catch {}
    })
    $m.Start()
}

# App entry
try {
    $initial = pB
    if ($initial.Status -ne "Online") {
        [System.Windows.Forms.MessageBox]::Show("No charger detected. Exiting.", "Notice", "OK", "Information")
        exit
    }

    zR
    [System.Windows.Forms.Application]::Run()
} catch {
    [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Fatal", "OK", "Error")
}
