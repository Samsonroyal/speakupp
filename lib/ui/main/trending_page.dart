import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:speakupp/api/polls/poll_call.dart';
import 'package:speakupp/common/app_enums.dart';
import 'package:speakupp/common/app_resourses.dart';
import 'package:speakupp/model/common/api_request.dart';
import 'package:speakupp/model/poll/poll_item.dart';
import 'package:speakupp/model/user/user_item_provider.dart';
import 'package:speakupp/ui/common/app_input_decorator.dart';
import 'package:speakupp/ui/common/app_progress_indicator.dart';
import 'package:speakupp/ui/polls/poll_item_view.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  bool _loading = false;
  final PollCall pollCall = GetIt.instance.get<PollCall>();
  final UserItemProvider userItemProvider =
      GetIt.instance.get<UserItemProvider>();
  List<PollItem> items = [];
  String nextUrl = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _uiReady(context));
  }

  void _uiReady(BuildContext buildContext) {
    items.clear();
    Map<String, dynamic> dataParams = {};
    var request = ApiRequest(
        url: AppResourses.appStrings.trendingPolls, data: dataParams);
    _fetchData(request);
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

  Widget _mainView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchAreaView(),
          AppProgressIndicator().inderminateProgress(_loading,
              color: AppResourses.appColors.primaryColor),
          _trendingPollsView()
        ],
      ),
    );
  }

  Widget _searchAreaView() {
    return Container(
      color: AppResourses.appColors.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        autocorrect: true,
        controller: _searchController,
        keyboardType: TextInputType.number,
        style:
            AppResourses.appTextStyles.textStyle(16, fontColor: Colors.white),
        decoration: AppInputDecorator.searchInputDecoration(
          "Search Polls",
          () {
            _searchController.text = "";
            _uiReady(context);
          },
        ),
      ),
    );
  }

  Widget _trendingPollsView() {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int position) {
          PollItem pollItem = items[position];
          return PollItemView().single(pollItem, (PollAction action) {});
        },
        separatorBuilder: (BuildContext context, int position) {
          return const SizedBox(
            height: 8,
          );
        },
        itemCount: items.length);
  }

  void _fetchData(ApiRequest request) {
    setState(() {
      _loading = true;
    });
    pollCall.allPolls(request).whenComplete(() {
      setState(() {
        _loading = false;
      });
    }).then((value) {
      setState(() {
        items.addAll(value.items);
        nextUrl = value.nextUrl ?? "";
      });
    }).onError((error, stackTrace) {});
  }
}
