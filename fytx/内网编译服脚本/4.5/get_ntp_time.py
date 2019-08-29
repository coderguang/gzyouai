import time
import sys
import os
import platform
if(platform.system() == "Linux"):
    import ntplib

ntp_time_format='%Y-%m-%d-%H.%M.%S'

def getNtpDatetime():
    try:
        client = ntplib.NTPClient()
        response = client.request('120.25.115.19', timeout=10)
        timestamp = time.localtime(response.tx_time)
        NtpDatetime = time.strftime(ntp_time_format, timestamp)
        return NtpDatetime
    except Exception:
        print('Can not connect NTP server, exit!')
	return ""
        
		
if __name__ == "__main__":
	ntp_time = getNtpDatetime()
	if (ntp_time == ""):
		sys.exit(3)
	print(ntp_time)
	sys.exit(0)
