<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="./static/icon.png" alt="Project logo" ></a>
 <br>

</p>

<h3 align="center">Robot Log Analyzer</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/da-huin/robot_log_anaylzer.svg)](https://github.com/da-huin/robot_log_anaylzer/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/da-huin/robot_log_anaylzer.svg)](https://github.com/da-huin/robot_log_anaylzer/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> 
    <br> 특정 로그를 분석하기 위해 만들어졌습니다.
</p>

## 📝 Table of Contents

- [Getting Started](#getting_started)
- [Acknowledgments](#acknowledgement)

### 🚀 Tutorial

1. 아래의 명령어로 도움말을 확인 할 수 있습니다.

     analyzer.sh -h 

1. 아래와 같이 사용합니다.

```bash
root@9162ce79488f:/app# bash index.sh sample.log -H 02-12    
================================================
FILENAME: sample.log
SEARCH: 
TIME: 02-12
START_HOUR: 02
END_HOUR: 12
TYPE: stat
SORT: asce
QUIET: 0
CURRENT: 0
SHORT: 0
LOG_TYPE: error
================================================
[INFO] file is exists
[INFO] seperating
[INFO] FILTER BY TIME 02 ~ 12
[INFO] CREATE STATISTICS
[INFO] file created: error_log.data, statistics.data
[INFO] COMPLETE
[ HOUR 05 ]
    713 [application][ERROR]: [500#ERROR_GENERAL] HTTP Request Failed	

[ HOUR 06 ]
     30 [application][ERROR]: [500#ERROR_GENERAL] HTTP Request Failed	
```

1. 아래와 같은 형식의 로그에서 동작합니다.

```
[2020-08-24 05:30:10] [some_service][ERROR]: HTTP Request Failed [('ABC', '`Log Message.'), ('dolor', 'Aliquam'), ('amet,', 'sed'), ('adipiscing', 'velit'), ('Phasellus', 'sed'), ('amet', 'auctor'), ('lacus.', 'ante'), ('a', 'elementum')]
```

## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Title icon made by [Freepik](https://www.flaticon.com/kr/authors/freepik).

- If you have a problem. please make [issue](https://github.com/da-huin/robot_log_anaylzer/issues).

- Please help develop this project 😀

- Thanks for reading 😄

