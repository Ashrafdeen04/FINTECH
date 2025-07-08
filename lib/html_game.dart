// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class HtmlPage extends StatefulWidget {
//   @override
//   _HtmlPageState createState() => _HtmlPageState();
// }

// class _HtmlPageState extends State<HtmlPage> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize WebView
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       WebView.platform = SurfaceAndroidWebView();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('HTML Page'),
//       ),
//       body: WebView(
//         initialUrl: Uri.dataFromString(
//           '''
//           <html>
//             <body>
//               <h1>Hello, World!</h1>
//               <p>This is a sample HTML content.</p>
//             </body>
//           </html>
//           ''',
//           mimeType: 'text/html',
//         ).toString(),
//         javascriptMode: JavascriptMode.unrestricted,
//       ),
//     );
//   }
// }
