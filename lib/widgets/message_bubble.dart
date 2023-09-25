import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  //첫 메시지
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  //이후 메시지
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;

  final String? userImage;
  //챗 버블 옆에 출력될 프로필이미지.
  //첫번째 메시지가 아니라면 필요없음.

  final String? username; //유저 이름. 프로필 이미지와 마찬가지로 첫번째가 아니면 필요 X.
  final String message;

  final bool
      isMe; //Controls how the MessageBubble will be aligned. true면 버블을 오른쪽에 정렬.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //일관된 디자인과 스타일 적용

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 20,
            // 내 메시지면 오른쪽에 정렬
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                userImage!,
              ),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 20,
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            //보낸 사람에 따라 메시지 보이는 위치 변경
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  //First messages in the sequence provide a visual buffer at the top.
                  if (isFirstInSequence)
                    const SizedBox(
                      height: 10,
                    ),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                      ),
                      child: Text(
                        username!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color.fromRGBO(53, 231, 189, 1)
                          : Colors.grey[200],
                      // Only show the message bubble's "speaking edge" if first in
                      // the chain.
                      // Whether the "speaking edge" is on the left or right depends
                      // on whether or not the message bubble is the current user.
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence //말풍선 모양 변경
                            ? Radius.zero
                            : const Radius.circular(20),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(20),
                        bottomLeft: const Radius.circular(20),
                        bottomRight: const Radius.circular(20),
                      ),
                    ),

                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    // Margin around the bubble.
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        // Add a little line spacing to make the text look nicer
                        // when multilined.
                        height: 1.3,
                        color: Colors.black,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
