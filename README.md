# Daemon Supervisor
Bash daemon supervisor.
This tool should check that the process is running and starts it in case is down. 
It takes following parameters:
- Seconds to wait between attempts to restart service
- Number of attempts before giving up
- Name of the process to supervise
- Check interval in seconds
- Generate logs in case of events.
