@echo off
mkdir "C:\Users\kawasaki\AppData\Local\Temp\firenvim" 2>nul
cd "C:\Users\kawasaki\AppData\Local\Temp\firenvim"

 "C:\Users\kawasaki\scoop\apps\neovim\current\bin\nvim.exe" --headless --cmd "let g:firenvim_config={'globalSettings':{},'localSettings':{'.*':{}}}|let g:firenvim_i=[]|let g:firenvim_o=[]|let g:Firenvim_oi={i,d,e->add(g:firenvim_i,d)}|let g:Firenvim_oo={t->[chansend(2,t)]+add(g:firenvim_o,t)}|let g:firenvim_c=stdioopen({'on_stdin':{i,d,e->g:Firenvim_oi(i,d,e)},'on_print':{t->g:Firenvim_oo(t)}})" --cmd "let g:started_by_firenvim = v:true" -c "call firenvim#run()"
