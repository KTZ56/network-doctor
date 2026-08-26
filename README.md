\# 🩺 Network Doctor



\*\*Network Doctor\*\* is a Windows network diagnostics and troubleshooting application built with \*\*Flutter\*\*.



It provides a modern, easy-to-use interface for monitoring network connectivity, diagnosing common network problems, inspecting network information, and performing a variety of network troubleshooting and analysis tasks.



> \*\*Status:\*\* Active Development 🚧



\---



\## 📸 Overview



Network Doctor brings essential network troubleshooting tools together in a single desktop application.



It is designed for:



\* Network administrators

\* IT support technicians

\* System administrators

\* Developers

\* Students learning networking

\* Anyone troubleshooting Windows network connectivity



\---



\## ✨ Features



\### 🌐 Network Information



View important information about your current network connection, including:



\* Network interface

\* IPv4 address

\* Subnet mask

\* Default gateway

\* DNS server

\* MAC address

\* DHCP status

\* Ethernet connection information

\* Wi-Fi connection information



\---



\### 🩺 Connectivity Diagnostics



Run automated connectivity tests to help identify network problems.



Network Doctor can test:



\* Default gateway connectivity

\* Internet connectivity

\* DNS functionality

\* Network health

\* Basic connectivity status



The diagnostic system can help determine whether a problem is likely to be related to:



```text

Computer

&#x20;  ↓

Network Adapter

&#x20;  ↓

Gateway

&#x20;  ↓

Internet

&#x20;  ↓

DNS

```



\---



\### 📡 Ping Test



Test connectivity and response times to network hosts.



Features include:



\* Host/IP ping testing

\* Response time

\* Packet success/failure

\* Connectivity status

\* Basic latency analysis



Useful for troubleshooting:



\* Network connectivity

\* High latency

\* Unreachable hosts

\* Gateway problems

\* Internet connectivity



\---



\### 🔎 DNS Lookup



Perform DNS lookups to investigate domain name resolution.



Useful for identifying:



\* DNS resolution problems

\* Domain records

\* DNS server behavior

\* Connectivity issues caused by DNS



\---



\### 🛣️ Traceroute



Trace the path packets take from your computer to a destination.



Network Doctor uses Windows `tracert` functionality to inspect network hops.



Useful for investigating:



\* Routing problems

\* High-latency hops

\* Unreachable destinations

\* Network paths

\* ISP routing issues



\---



\### 🔌 Port Scanner



Check network ports on a target host.



Useful for:



\* Network troubleshooting

\* Service discovery

\* Checking whether services are reachable

\* Basic network analysis



> Use port scanning only on systems and networks you own or have permission to test.



\---



\### 🖥️ Network Device Scanner



Discover devices available on the local network.



The device scanner can help identify:



\* Network devices

\* IP addresses

\* Local hosts

\* Devices connected to the network



\---



\### 🚀 Speed Test



Measure network performance and provide information about connection speed.



Useful for:



\* Internet connection testing

\* Performance troubleshooting

\* Comparing network conditions

\* Identifying slow connections



\---



\### 📊 Traffic Monitor



Monitor network traffic and activity in real time.



The traffic monitoring functionality is designed to help users understand network usage and activity on their Windows machine.



\---



\### 🌍 IP Geolocation



Look up geographic information associated with an IP address.



Information can include:



\* Country

\* Region

\* City

\* Network information

\* IP-related geographic data



\---



\### 🏢 ASN Lookup



Investigate Autonomous System information associated with an IP address or network.



Useful for understanding:



\* Autonomous System Numbers

\* Network ownership

\* Internet service providers

\* Network infrastructure



\---



\### 🔍 WHOIS Lookup



Perform WHOIS/RDAP-based domain information lookups.



Useful for investigating:



\* Domain registration information

\* Domain status

\* Registrar information

\* Registration-related details



\---



\## 🧰 Tools



Network Doctor currently includes the following tools:



| Tool                   | Purpose                               |

| ---------------------- | ------------------------------------- |

| 🌐 Network Information | View local network configuration      |

| 🩺 Diagnostics         | Diagnose connectivity problems        |

| 📡 Ping                | Test host connectivity and latency    |

| 🔎 DNS Lookup          | Investigate DNS resolution            |

| 🛣️ Traceroute         | Analyze network routes                |

| 🔌 Port Scanner        | Check network ports                   |

| 🖥️ Device Scanner     | Discover local network devices        |

| 🚀 Speed Test          | Test network performance              |

| 📊 Traffic Monitor     | Monitor network traffic               |

| 🌍 IP Geolocation      | Investigate IP geographic information |

| 🏢 ASN Lookup          | Investigate autonomous systems        |

| 🔍 WHOIS Lookup        | Investigate domain information        |



\---



\## 🖥️ Platform Support



\### Windows



Network Doctor is currently focused on \*\*Windows Desktop\*\*.



The application uses Windows networking capabilities for several diagnostic functions.



> Other platforms may be supported in the future.



\---



\## 🛠️ Technology Stack



Network Doctor is built using:



\* \*\*Flutter\*\*

\* \*\*Dart\*\*

\* \*\*Provider\*\*

\* \*\*Windows Desktop\*\*

\* REST/RDAP-based network services

\* Windows networking utilities



\### Architecture



The project follows a modular structure separating models, providers, services, screens, and reusable widgets.



```text

lib/

├── models/

├── providers/

├── screens/

│   └── tools/

├── services/

├── theme/

├── widgets/

└── main.dart

```



\### Models



Network-related data models include:



\* `NetworkInfo`

\* `PingResult`

\* `DnsResult`

\* `TracerouteResult`

\* `PortScanResult`

\* `NetworkDevice`

\* `SpeedTestResult`

\* `TrafficStats`

\* `WhoisResult`

\* `IpGeolocationResult`

\* `AsnResult`

\* `Diagnosis`



\### Services



The application contains dedicated services for network operations, including:



\* `WindowsNetworkService`

\* `PingService`

\* `DnsService`

\* `TracerouteService`

\* `PortScannerService`

\* `NetworkScannerService`

\* `DeviceScannerService`

\* `SpeedTestService`

\* `TrafficMonitorService`

\* `WhoisService`

\* `IpGeolocationService`

\* `AsnService`

\* `DiagnosticService`



\---



\## 📁 Project Structure



```text

network-doctor/

│

├── assets/

│   └── images/

│

├── installer/

│   ├── NetworkDoctor.iss

│   ├── after\_installation.txt

│   ├── information.txt

│   └── license.txt

│

├── lib/

│   ├── models/

│   ├── providers/

│   ├── screens/

│   │   └── tools/

│   ├── services/

│   ├── theme/

│   ├── widgets/

│   └── main.dart

│

├── test/

│

├── windows/

│

├── analysis\_options.yaml

├── pubspec.yaml

├── pubspec.lock

├── README.md

└── .gitignore

```



\---



\## 🚀 Getting Started



\### Prerequisites



Before building Network Doctor from source, install:



\* Windows 10 or later

\* Flutter SDK

\* Dart SDK

\* Visual Studio with Windows Desktop development tools

\* Git



Verify Flutter:



```powershell

flutter doctor

```



Make sure Windows Desktop development is available:



```powershell

flutter devices

```



You should see a Windows device.



\---



\## 📥 Clone the Repository



Clone the project:



```powershell

git clone https://github.com/KTZ56/network-doctor.git

```



Enter the project directory:



```powershell

cd network-doctor

```



\---



\## 📦 Install Dependencies



Run:



```powershell

flutter pub get

```



\---



\## ▶️ Run Network Doctor



Run the application on Windows:



```powershell

flutter run -d windows

```



\---



\## 🏗️ Build the Windows Application



Create a release build:



```powershell

flutter build windows --release

```



The generated application can be found under:



```text

build\\windows\\x64\\runner\\Release\\

```



\---



\## 📦 Build the Installer



Network Doctor includes an Inno Setup installer configuration.



The installer configuration is located at:



```text

installer\\NetworkDoctor.iss

```



Open the `.iss` file using \*\*Inno Setup\*\* and build the installer.



The generated installer can then be distributed through GitHub Releases.



\---



\## 🔐 Security \& Responsible Use



Network Doctor contains tools that can interact with network hosts and services.



Some features, including:



\* Port scanning

\* Device discovery

\* Network scanning

\* WHOIS/RDAP lookups



should only be used on systems and networks where you have authorization.



\### Responsible Use



Do not use Network Doctor to:



\* Scan networks without permission

\* Access systems without authorization

\* Circumvent security controls

\* Disrupt network services

\* Perform unauthorized security testing



The project is intended for legitimate network administration, troubleshooting, education, and authorized testing.



\---



\## 🧪 Development



Check the project for Dart analysis issues:



```powershell

flutter analyze

```



Run tests:



```powershell

flutter test

```



Format Dart code:



```powershell

dart format lib test

```



\---



\## 🔄 Updating the Project



To get the latest version:



```powershell

git pull

```



After making changes:



```powershell

git add .

git commit -m "Describe your changes"

git push

```



\---



\## 🗺️ Roadmap



Planned and potential improvements include:



\* \[ ] Improved network health scoring

\* \[ ] More advanced diagnostics

\* \[ ] Better Wi-Fi information

\* \[ ] Advanced network device discovery

\* \[ ] Improved traffic monitoring

\* \[ ] Network history and statistics

\* \[ ] Export diagnostic reports

\* \[ ] PDF/HTML diagnostic reports

\* \[ ] Improved DNS analysis

\* \[ ] More network protocol information

\* \[ ] Automatic troubleshooting recommendations

\* \[ ] Improved Windows installer

\* \[ ] GitHub Actions automated builds

\* \[ ] GitHub Releases

\* \[ ] Additional platform support



\---



\## 🤝 Contributing



Contributions, suggestions, bug reports, and feature requests are welcome.



\### Development Workflow



1\. Fork the repository.

2\. Create a feature branch.



```powershell

git checkout -b feature/my-feature

```



3\. Make your changes.

4\. Run analysis and tests.



```powershell

flutter analyze

flutter test

```



5\. Commit your changes.



```powershell

git add .

git commit -m "Add my feature"

```



6\. Push your branch.



```powershell

git push origin feature/my-feature

```



7\. Open a Pull Request.



\---



\## 🐛 Reporting Issues



If you discover a bug, please open a GitHub Issue and include:



\* Windows version

\* Network connection type

\* Network Doctor version

\* Steps to reproduce the problem

\* Expected behavior

\* Actual behavior

\* Relevant error messages or screenshots



\---



\## 📄 License



This project is currently under active development.



A formal open-source license will be added before the project is distributed as an open-source release.



\---



\## 👨‍💻 Author



\*\*James Jok\*\*



GitHub:



https://github.com/KTZ56



\---



\## ⭐ Support the Project



If you find Network Doctor useful:



\* ⭐ Star the repository

\* 🐛 Report bugs

\* 💡 Suggest features

\* 🔧 Contribute improvements

\* 📢 Share the project



\---



\## 📌 Project Status



Network Doctor is an actively developing Windows network diagnostics application.



The goal is to provide a practical, modern, and accessible toolkit for understanding and troubleshooting computer networks from a single desktop application.



\---



\*\*Network Doctor — Diagnose. Analyze. Understand your Network. 🩺🌐\*\*



