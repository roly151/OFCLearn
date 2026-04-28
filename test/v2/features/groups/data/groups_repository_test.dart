import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ofc_learn_v2/v2/core/network/api_client.dart';
import 'package:ofc_learn_v2/v2/core/storage/token_storage.dart';
import 'package:ofc_learn_v2/v2/features/groups/data/groups_repository.dart';

void main() {
  test('fetchGroupFeed only returns site 1 activity', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    unawaited(
      server.forEach((request) {
        expect(request.uri.path, '/groups/7/feed');
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode(<Map<String, Object?>>[
            _activityJson(id: 101, sourceBlogId: 1, name: 'Site One Coach'),
            _activityJson(id: 205, sourceBlogId: 5, name: 'Site Five Coach'),
          ]),
        );
        unawaited(request.response.close());
      }),
    );

    final repository = GroupsRepository(
      ApiClient(
        baseUrl: 'http://${server.address.host}:${server.port}',
        tokenStorage: _NoopTokenStorage(),
      ),
      wpJsonBaseUrl: 'http://${server.address.host}:${server.port}',
    );

    final feed = await repository.fetchGroupFeed(7);

    expect(feed.map((item) => item.id), <int>[101]);
    expect(feed.single.sourceBlogId, 1);
    expect(feed.single.name, 'Site One Coach');
  });

  test('fetchGroupDiscussions reads group discussion topics', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    unawaited(
      server.forEach((request) {
        expect(request.uri.path, '/groups/7/discussions');
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode(<Map<String, Object?>>[
            <String, Object?>{
              'id': 49297,
              'user_name': 'Sean Douglas',
              'user_image': '',
              'Title': 'Welcome discussion',
              'primary_link': 'https://example.test/groups/topic/1/',
              'date_recorded': '2026-04-23',
              'Total_member': 3,
            },
          ]),
        );
        unawaited(request.response.close());
      }),
    );

    final repository = GroupsRepository(
      ApiClient(
        baseUrl: 'http://${server.address.host}:${server.port}',
        tokenStorage: _NoopTokenStorage(),
      ),
      wpJsonBaseUrl: 'http://${server.address.host}:${server.port}',
    );

    final discussions = await repository.fetchGroupDiscussions(7);

    expect(discussions.single.id, 49297);
    expect(discussions.single.title, 'Welcome discussion');
    expect(discussions.single.replyCount, 3);
  });

  test('fetchGroupDiscussion reads topic detail and replies', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    unawaited(
      server.forEach((request) {
        expect(request.uri.path, '/groups/7/discussions/49297');
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode(<String, Object?>{
            'id': 49297,
            'group_id': 7,
            'forum_id': 49296,
            'author_name': 'Sean Douglas',
            'author_avatar_url': '',
            'title': 'Welcome discussion',
            'content': '<p>Welcome to the group.</p>',
            'primary_link': 'https://example.test/groups/topic/1/',
            'date_recorded': '2026-04-23',
            'reply_count': 1,
            'replies': <Map<String, Object?>>[
              <String, Object?>{
                'id': 49310,
                'author_name': 'Coach Example',
                'author_avatar_url': '',
                'content': '<p>Thanks Sean.</p>',
                'primary_link': 'https://example.test/groups/topic/1/#post-49310',
                'date_recorded': '2026-04-24',
              },
            ],
          }),
        );
        unawaited(request.response.close());
      }),
    );

    final repository = GroupsRepository(
      ApiClient(
        baseUrl: 'http://${server.address.host}:${server.port}',
        tokenStorage: _NoopTokenStorage(),
      ),
      wpJsonBaseUrl: 'http://${server.address.host}:${server.port}',
    );

    final discussion = await repository.fetchGroupDiscussion(
      groupId: 7,
      discussionId: 49297,
    );

    expect(discussion.title, 'Welcome discussion');
    expect(discussion.contentHtml, '<p>Welcome to the group.</p>');
    expect(discussion.replies.single.authorName, 'Coach Example');
  });

  test('createGroupDiscussionReply posts a topic reply', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    unawaited(
      server.forEach((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/groups/7/discussions/49297');
        final body = await utf8.decoder.bind(request).join();
        expect(jsonDecode(body), <String, Object?>{'message': 'Thanks Sean.'});
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode(<String, Object?>{
            'id': 49311,
            'message': 'Reply posted successfully.',
          }),
        );
        unawaited(request.response.close());
      }),
    );

    final repository = GroupsRepository(
      ApiClient(
        baseUrl: 'http://${server.address.host}:${server.port}',
        tokenStorage: _NoopTokenStorage(),
      ),
      wpJsonBaseUrl: 'http://${server.address.host}:${server.port}',
    );

    final result = await repository.createGroupDiscussionReply(
      groupId: 7,
      discussionId: 49297,
      message: 'Thanks Sean.',
    );

    expect(result.message, 'Reply posted successfully.');
  });
}

Map<String, Object?> _activityJson({
  required int id,
  required int sourceBlogId,
  required String name,
}) {
  return <String, Object?>{
    'id': id,
    'user_id': 1,
    'source_blog': sourceBlogId,
    'name': name,
    'action': '$name posted an update',
    'component': 'groups',
    'content': <String, Object?>{'rendered': '<p>Hello</p>'},
    'date': '2026-04-23',
    'link': 'https://example.test/activity/$id',
    'type': 'activity_update',
  };
}

class _NoopTokenStorage extends TokenStorage {
  _NoopTokenStorage() : super(const FlutterSecureStorage());

  @override
  Future<String?> readToken() async => null;
}
