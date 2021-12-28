unit RxPascal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs;

type

  TFuncNoArgsString = function(): String;
  TProcOneArg = procedure(arg: string);

  { TObservable }

  TObservable = class
    private
      FNext: string;
      Ffunction: TFuncNoArgsString;
      FConsumers: TFPObjectList;


    public
      procedure Publish;
      procedure ExecuteFunction;
      constructor Create(AFunction: TFuncNoArgsSTring);
      procedure Subscribe(AFunction: TProcOneArg);

  end;

  { TObservableExecThread }

  TObservableExecThread = class(TThread)
    private
      FObservable: TObservable;
    protected
      procedure Execute; override;
    public
      constructor Create(AObservable: TObservable);
  end;

  { TObservablePublishThread }

  TObservablePublishThread = class(TThread)
    private
      FObservable: TObservable;
    protected
      procedure Execute; override;
    public
      constructor Create(AObservable: TObservable);
  end;

  { TObservableConsumeThread }

  TObservableConsumeThread = class(TThread)
    private
      FFunction: TProcOneArg;
      FArg: string;
    protected
      procedure Execute; override;
    public
      constructor Create(AFunction: TProcOneArg; AArg: string);
  end;

implementation

{ TObservableConsumeThread }

procedure TObservableConsumeThread.Execute;
begin
  FFunction(Farg);
end;

constructor TObservableConsumeThread.Create(AFunction: TProcOneArg; AArg: string);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FFunction := AFunction;
  FArg := AArg;
end;


{ TObservablePublishThread }

procedure TObservablePublishThread.Execute;
begin
  FObservable.Publish;
end;

constructor TObservablePublishThread.Create(AObservable: TObservable);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FObservable := AObservable;
end;

{ TObservableExecThread }

procedure TObservableExecThread.Execute;
begin
  FObservable.ExecuteFunction;
end;

constructor TObservableExecThread.Create(AObservable: TObservable);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FObservable := AObservable;
end;

{ TObservable }

procedure TObservable.Publish;
var
  i: integer;
  Casted: TProcOneArg;
  AObsThread: TObservableConsumeThread;
begin

  while (True) do
  begin
    if FNext <> '' then
    begin
      if FConsumers.Count > 0 then
      begin
        for i := 0 to FConsumers.Count - 1 do
        begin
          Casted := TProcOneArg(FConsumers[i]);
          AObsThread := TObservableConsumeThread.Create(Casted, FNext);
          AObsThread.Start;
        end;
        FNext := '';
      end;
    end;
  end;
end;

procedure TObservable.ExecuteFunction;
begin

  FNext := FFunction();
end;

constructor TObservable.Create(AFunction: TFuncNoArgsSTring);
var
  ExecThread: TObservableExecThread;
  PublishThread: TObservablePublishThread;
begin
  FNext := '';
  FFunction := AFunction;
  FConsumers := TFPObjectList.Create(True);
  ExecThread := TObservableExecThread.Create(self);
  PublishThread := TObservablePublishThread.Create(self);
  ExecThread.Start;
  PublishThread.Start;
end;

procedure TObservable.Subscribe(AFunction: TProcOneArg);
begin
  FConsumers.Add(TObject(AFunction));
end;

end.

