program VSpascalConfigure;
uses Classes, Process, SysUtils, Zipper, Crt;
var answer : boolean;
    ansstr : ansistring;
    appdata : string;
    fdata : ansistring;
    temp : char;
    fchar : file of char;
    i : integer;


procedure CleanBuffer();
begin
    while KeyPressed do
        readkey;
end;

function ReadYN(const prompt : string) : boolean;
var response : char;
begin
    CleanBuffer();
    write(prompt);
    response := upcase(readkey);
    writeln(response);
    while (response <> 'Y') and (response <> 'N') do
    begin
        writeln('Please enter Y/N!');
        write(prompt);
        response := upcase(readkey);
        writeln(response);
    end;
    ReadYN := response = 'Y';
end;

procedure RunProcessSync(prog : string; args : array of string);
var _process : TProcess;
var str : string;
begin
    _process := TProcess.Create(nil);
    _process.Executable := prog;
    for str in args do
        _process.Parameters.Add(str);
    _process.Options := [poWaitOnExit];
    _process.Execute;
    _process.Free;
end;

procedure EnsureDirOrExit(dir : string);
begin
    if not DirectoryExists(dir) then
        if not CreateDir(dir) then
        begin
            writeln('< Failed to create a directory required! Please try to start the program again.');
            readkey;
            Halt(1);
        end;
end;


begin
    answer := ReadYN('> Is VS code installed on this computer (Y/N)? ');
    if not answer then
    begin
        repeat
        begin
            writeln('  > Starting the installer now...');
            RunProcessSync('res/VSCodeUserSetup', []);
        end;
        until ReadYN('  > Is VS code installed successfully (Y/N)? ');
    end;
    writeln('> Installing Visual Studio Code Extensions...');
    writeln('  > Installing Extension Pascal');
    RunProcessSync('code.cmd', ['--install-extension', 'alefragnani.pascal']);
    writeln('  > Installing Extension Code Runner');
    RunProcessSync('code.cmd', ['--install-extension', 'formulahendry.code-runner']);
    writeln('< Extensions installed');
    answer := ReadYN('> Do you want to use the settings suggested (Y/N) (Warning: only do this when VS code is not set up)? ');
    if answer then
    begin
        appdata := GetEnvironmentVariable('AppData');
        EnsureDirOrExit(appdata + '\Code');
        EnsureDirOrExit(appdata + '\Code\User');
        Assign(fchar, appdata + '\Code\User\settings.json');
        Reset(fchar);
        if FileSize(fchar) <> 0 then
        begin
            fdata := '';
            for i := 1 to FileSize(fchar) do
            begin
                read(fchar, temp);
                fdata += temp;
            end;
            fdata := Trim(fdata);
            if fdata[Length(fdata)] <> '}' then
            begin
                writeln('< The file can''t be read properly.');
                Close(fchar);
                readkey;
                Halt(1);
            end;
            fdata := copy(fdata, 1, Length(fdata) - 1) + ',';
        end
        else
        begin
            fdata := '{';
        end;
        writeln('  > Please specify the path of "ptop.exe" (Use \\ [double backward slash] as directory delimitor):');
        write('  < ');
        readln(ansstr);
        fdata += '"pascal.format.indent":4,"pascal.formatter.engine":"ptop","pascal.formatter.enginePath":"' +  ansstr;
        fdata +=  '","code-runner.clearPreviousOutput":true,"code-runner.defaultLanguage":"pascal","code-runner.executorMap":{"javascript":"node","java":"cd $dir && javac $fileName && java $fileNameWithoutExt","c":"cd $dir && gcc $fileName -o $fileNameWithoutExt && $dir$fileNameWithoutExt","cpp":"cd $dir && g++ $fileName -o $fileNameWithoutExt && $dir$fileNameWithoutExt","objective-c":"cd $dir && gcc -framework Cocoa $fileName -o $fileNameWithoutExt && $dir$fileNameWithoutExt","php":"php","python":"python -u","perl":"perl","perl6":"perl6","ruby":"ruby","go":"go run","lua":"lua","groovy":"groovy","powershell":"powershell -ExecutionPolicy ByPass -File","bat":"cmd /c","shellscript":"bash","fsharp":"fsi","csharp":"scriptcs","vbscript":"cscript //Nologo","typescript":"ts-node","coffeescript":"coffee","scala":"scala","swift":"swift","julia":"julia","crystal":"crystal","ocaml":"ocaml","r":"Rscript","applescript":"osascript","clojure":"lein exec","haxe":"haxe --cwd $dirWithoutTrailingSlash --run $fileNameWithoutExt","rust":"cd $dir && rustc $fileName && $dir$fileNameWithoutExt","racket":"racket","ahk":"autohotkey","autoit":"autoit3","dart":"dart","pascal":"cd $dir && fpc $fileName && start $fileNameWithoutExt","d":"cd $dir && dmd $fileName && $dir$fileNameWithoutExt","haskell":"runhaskell","nim":"nim compile --verbosity:0 --hints:off --run"},"code-runner.executorMapByFileExtension":{".vb":"cd $dir && vbc /nologo $fileName && $dir$fileNameWithoutExt",".vbs":"cscript //Nologo",".scala":"scala",".jl":"julia",".cr":"crystal",".ml":"ocaml",".exs":"elixir",".hx":"haxe --cwd $dirWithoutTrailingSlash --run $fileNameWithoutExt",".rkt":"racket",".ahk":"autohotkey",".au3":"autoit3",".kt":"cd $dir && kotlinc $fileName -include-runtime -d $fileNameWithoutExt.jar && java -jar $fileNameWithoutExt.jar",".kts":"kotlinc -script",".dart":"dart",".pas":"cd $dir && fpc $fileName && start $fileNameWithoutExt",".pp":"cd $dir && fpc $fileName && $fileNameWithoutExt",".d":"cd $dir && dmd $fileName && $dir$fileNameWithoutExt",".hs":"runhaskell",".nim":"nim compile --verbosity:0 --hints:off --run",".csproj":"dotnet run --project",".fsproj":"dotnet run --project"},"code-runner.ignoreSelection":true,"code-runner.saveFileBeforeRun":true}';
        Rewrite(fchar);
        for i := 1 to Length(fdata) do
            write(fchar, fdata[i]);
        Close(fchar);
        writeln('< Settings added to Visual Studio Code successfully.');
    end;
    answer := ReadYN('> Set up GNU Global to make the extension Pascal complete (Y/N)? ');
    if answer then
        writeln('-- Not Implemented Yet --');
    write('Setup all done, press any key to exit...');
    readkey;
end.