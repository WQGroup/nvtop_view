import 'dart:async';
import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import './settings/settings_controller.dart';
import './settings/settings_view.dart';
import 'dart:convert';
import './sample_feature/sample_item.dart';
// 添加饼图依赖
import 'package:flutter/material.dart';

import 'window/window_widget.dart';
import 'package:http/http.dart' as http;

const String mockData = '''
{"host_system_infos":{"cpu_percent":8.072916666666668,"memory":{"total":34261680128,"available":10824470528,"used":23437209600,"usedPercent":68,"free":10824470528}},"gpu_driver_infos":{"driver_version":"536.23","nvml_version":"12.536.23","cuda_driver_version":12020},"gpu_infos":[{"index":0,"name":"NVIDIA GeForce RTX 2070 SUPER","brand_type":5,"uuid":"GPU-c03a58d0-d946-11fc-6e3e-e0156cac7377","fan":25,"temperature":33,"utilization_rates":{"gpu":14,"memory":7},"memory":{"total":8589934592,"free":6905942016,"used":1683992576},"power":{"usage":255000,"limit":20759},"compute_capability":{"major":7,"minor":5},"processes":{"11416":{"name":"C:_Users_Shawn_AppData_Local_Programs_Microsoft VS Code Insiders_Code - Insiders.exe","pid":11416,"u_sample":{"pid":11416,"time_stamp":1699588368175185,"sm_util":5,"mem_util":1,"enc_util":0,"dec_util":0}},"36996":{"name":"D:_Flutter_nvimonitor_nvimonitor_build_windows_runner_Debug_nvimonitor.exe","pid":36996,"u_sample":{"pid":36996,"time_stamp":1699588390567238,"sm_util":2,"mem_util":0,"enc_util":0,"dec_util":0}}}}],"process_infos":[{"pid":11416,"name":"C:_Users_Shawn_AppData_Local_Programs_Microsoft VS Code Insiders_Code - Insiders.exe","environ":[],"cmd_line":"_C:_Users_Shawn_AppData_Local_Programs_Microsoft VS Code Insiders_Code - Insiders.exe_ --type=gpu-process --user-data-dir=_C:_Users_Shawn_AppData_Roaming_Code - Insiders_ --gpu-preferences=WAAAAAAAAADgAAAMAAAAAAAAAAAAAAAAAABgAAAAAAA4AAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGAAAAAAAAAAYAAAAAAAAAAgAAAAAAAAACAAAAAAAAAAIAAAAAAAAAA== --mojo-platform-channel-handle=1652 --field-trial-handle=1648,i,12645196615295792644,9274922829561600410,262144 --disable-features=CalculateNativeWinOcclusion,SpareRendererForSitePerProcess,WinRetrieveSuggestionsOnlyOnDemand /prefetch:2","cpu_percent":0.2445686039773331,"mem_percent":0.36801222,"mem_info":{"rss":126087168,"vms":574263296,"hwm":0,"data":0,"stack":0,"locked":0,"swap":0},"gpu_u_sample":[{"pid":11416,"time_stamp":1699588368175185,"sm_util":5,"mem_util":1,"enc_util":0,"dec_util":0}]},{"pid":36996,"name":"D:_Flutter_nvimonitor_nvimonitor_build_windows_runner_Debug_nvimonitor.exe","environ":[],"cmd_line":"D:_Flutter_nvimonitor_nvimonitor_build_windows_runner_Debug_nvimonitor.exe","cpu_percent":0.21582926134188615,"mem_percent":0.66779697,"mem_info":{"rss":228798464,"vms":266682368,"hwm":0,"data":0,"stack":0,"locked":0,"swap":0},"gpu_u_sample":[{"pid":36996,"time_stamp":1699588390567238,"sm_util":2,"mem_util":0,"enc_util":0,"dec_util":0}]}]}
  ''';

String mockFetch() {
  // 随机生成数据
  var cpu_usage = (Random().nextDouble() * 100).toInt();
  var cpu_usage2 = (Random().nextDouble() * 100).toInt();

  return '''
  {
    "system_info": {
      "cpu_usage": $cpu_usage, 
      "gpu_usage": 75,
      "total_ram": 16,
      "used_ram": 8,
      "total_gpu_ram": 8,
      "used_gpu_ram": 4,
      "gpu_power": 100,
      "gpu_max_power": 150,
      "cpu_frequency": 2.5,
      "cpu_max_frequency": 3.0
    },
    "process_list": [
      {
        "pid": 1234,
        "cpu_usage": $cpu_usage2,
        "gpu_usage": 10,
        "used_ram": 500,
        "vram_usage": 100
      },
      {
        "pid": 51234,
        "cpu_usage": 20,
        "gpu_usage": 10,
        "used_ram": 500,
        "vram_usage": 100
      },
      {  
        "pid": 5678,
        "cpu_usage": 10,
        "gpu_usage": 5,
        "used_ram": 200,
        "used_gpu_ram": 50
      },
      {
        "pid": 9123,
        "cpu_usage": 5,
        "gpu_usage": 2,
        "used_ram": 100,
        "used_gpu_ram": 20  
      }
    ]
  }
  ''';
}

// 增加API调用接口
Future<String> fetchData() async {
  // 从 http://127.0.0.1:19035/infos/v1/host 读取数据
  var response = await http.get(Uri.parse('http://127.0.0.1:19035/infos/v1/host'));
  return response.body;

  // 调用 MOCK API
  return await Future.delayed(Duration(milliseconds: 500), () {
    // return mockFetch();
    return mockData;
  });
}

class MyHomePage extends StatefulWidget {
  static const routeName = '/home';
  final SettingsController controller;
  const MyHomePage({
    Key? key,
    required this.controller,
  }) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  dynamic? host_system_infos;
  dynamic? gpu_driver_infos;
  List<dynamic>? gpuList;
  List<dynamic>? processList;

  @override
  void initState() {
    super.initState();
    _startFetching();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  late Timer _timer;

  void _startFetching() {
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _fetchData());
  }

  void _fetchData() async {
    var data = await fetchData();
    var jsonData = jsonDecode(data);
    setState(() {
      host_system_infos = jsonData?['host_system_infos'];
      gpu_driver_infos = jsonData?['gpu_driver_infos'];
      gpuList = jsonData?['gpu_infos'];
      processList = jsonData?['process_infos'];
      // processList = List.from(jsonData['process_list']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
        color: const Color(0xFF805306),
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Row(
                children: [Expanded(child: MoveWindow()), const WindowButtons()],
              ),
            ),
            // 向上 marge 20 pix
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _percent('CPU: ${(host_system_infos?['cpu_percent'])?.toStringAsFixed(2)}%', ((host_system_infos?['cpu_percent']) ?? 0.0) / 100.0,
                    progressColor: Colors.red),
                _percent(
                    'RAM: ${((host_system_infos?['memory']['used'] ?? 0.0) / 1024.0 / 1024 / 1024)?.toStringAsFixed(2)}/${((host_system_infos?['memory']['total'] ?? 0.0) / 1024.0 / 1024 / 1024)?.toStringAsFixed(2)}GB',
                    1.0 * ((host_system_infos?['memory']['used']) ?? 0.0) / ((host_system_infos?['memory']['total']) ?? 1.0)),
                _percent('GPU: %', 19.0 / 100.0, progressColor: Colors.yellowAccent),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: SizedBox()),
                Text(gpu_driver_infos?['driver_version'] ?? ""),
                const SizedBox(width: 10),
                Text("${(gpu_driver_infos?['cuda_driver_version'] ?? 0) ~/ 1000}.${(gpu_driver_infos?['cuda_driver_version'] ?? 0) % 1000 ~/ 10}"),
              ],
            ),
            _buildGpuList(gpuList),
            Expanded(
              child: _buildProcessList(processList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _percent(String text, double percent, {Color? progressColor}) {
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 15.0,
      percent: percent,
      progressColor: progressColor ?? Colors.green,
      center: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGpuList(List<dynamic>? gpuList) {
    if (gpuList == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // 将 processList 根据 pid 排序
    gpuList.sort((a, b) => a['pid'].compareTo(b['pid']));
    return ListView.builder(
      shrinkWrap: true,
      itemCount: gpuList.length,
      itemBuilder: (context, index) {
        var gpu = gpuList[index];
        return ListTile(
          title: Text(
            gpu['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // 添加间隔
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Spacer(),
              SizedBox(
                width: 100,
                child: Text('${gpu?['temperature']}℃'),
              ),
              SizedBox(
                width: 100,
                child: Text('GPU ${gpu?['utilization_rates']?['gpu']}%'),
              ),
              SizedBox(
                width: 200,
                child: Text(
                    'GRAM: ${((gpu?['memory']?['used'] ?? 0.0) / 1024.0 / 1024 / 1024)?.toStringAsFixed(2)}/${((gpu?['memory']?['total'] ?? 0.0) / 1024.0 / 1024 / 1024)?.toStringAsFixed(2)}GB (${gpu?['utilization_rates']?['memory']}%)'),
              ),
            ],
          ),
        );
        ;
      },
    );
  }

  Widget _buildProcessList(List<dynamic>? processList) {
    if (processList == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // 将 processList 根据 pid 排序
    processList.sort((a, b) => a['pid'].compareTo(b['pid']));
    return ListView.builder(
      itemCount: processList.length,
      itemBuilder: (context, index) {
        var process = processList[index];
        return _buildProcessRow(process);
      },
    );
  }

  Widget _buildProcessRow(Map processInfo) {
    return ListTile(
      title: Row(children: [
        Text(
          'PID: ${processInfo['pid']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Text(
          '${processInfo['name']}',
          style: const TextStyle(fontSize: 12),
        ),
      ]),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('CPU: ${processInfo['cpu_percent'].toStringAsFixed(2)}%'),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: Text(
                'RAM: ${processInfo['mem_percent'].toStringAsFixed(2)}%    ${(processInfo['mem_info']['rss'].toInt() / 1024.0 / 1024 / 1024).toStringAsFixed(2)}GB'),
          ),
          const SizedBox(width: 10),
          Column(
              children: (processInfo['gpu_u_sample'].map<Widget>((item) =>
                  Text('GPU ${processInfo['gpu_u_sample'].indexOf(item)}: sm_util=${item['sm_util'].toString()}%, mem_util=${item['mem_util']}%'))).toList())
        ],
      ),
    );
  }
}
