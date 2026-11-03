function ggg(){
        g++ -std=c++17 $args
} 
function gg+(){
        g++ -std=c++20 $args
} 
function acg(){
        g++ -std=c++17 -I C:\include $args
}

function rust_make(){
	Param($n)
    mv  src $n
    rm .gitignore
    rm Cargo.lock
    rm Cargo.toml
}

function lg(){
  lazygit
}

function alal(){
  alacritty
}

function cdcd(){
  cd C:\Users\kawasaki\Desktop\vscode
}

function att(){
atcoder-tools $args
}

function lm(){
nvim -u "C:\Users\kawasaki\AppData\Local\nvim-lazy\init.lua"
}


function ds {
    & "C:\Users\kawasaki\.config\emacs\bin\doom.ps1" sync
}

chcp 65001
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')


Invoke-Expression (&starship init powershell)






function ovim {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
  )
  $old = $env:NVIM_APPNAME
  try {
    $env:NVIM_APPNAME = "ovim"
    nvim @Args
  } finally {
    if ($null -eq $old) { Remove-Item Env:NVIM_APPNAME -ErrorAction SilentlyContinue }
    else { $env:NVIM_APPNAME = $old }
  }
}

function tvim {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
  )
  $old = $env:NVIM_APPNAME
  try {
    $env:NVIM_APPNAME = "tvim"
    nvim @Args
  } finally {
    if ($null -eq $old) { Remove-Item Env:NVIM_APPNAME -ErrorAction SilentlyContinue }
    else { $env:NVIM_APPNAME = $old }
  }
}

function obvim {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
  )
  $old = $env:NVIM_APPNAME
  try {
    $env:NVIM_APPNAME = "obvim"
    nvim @Args
  } finally {
    if ($null -eq $old) { Remove-Item Env:NVIM_APPNAME -ErrorAction SilentlyContinue }
    else { $env:NVIM_APPNAME = $old }
  }
}

function nvchad {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
  )
  $old = $env:NVIM_APPNAME
  try {
    $env:NVIM_APPNAME = "nvchad"
    nvim @Args
  } finally {
    if ($null -eq $old) { Remove-Item Env:NVIM_APPNAME -ErrorAction SilentlyContinue }
    else { $env:NVIM_APPNAME = $old }
  }
}

function normal {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
  )
  $old = $env:NVIM_APPNAME
  try {
    $env:NVIM_APPNAME = "normal"
    nvim @Args
  } finally {
    if ($null -eq $old) { Remove-Item Env:NVIM_APPNAME -ErrorAction SilentlyContinue }
    else { $env:NVIM_APPNAME = $old }
  }
}



function init-ai-memory {
    powershell -ExecutionPolicy Bypass -File "C:\Users\kawasaki\powershell_scripts\init-ai-memory.ps1" @args
}
oh-my-posh init pwsh --config 'C:\Users\kawasaki\AppData\Local\omp-manager\themes\paradox.omp.json' | Invoke-Expression  # [omp-manager]
