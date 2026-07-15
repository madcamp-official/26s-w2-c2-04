# 26s-w2-c2-04

## 공통과제 II : 협업형 실전 산출물 제작 (2인 1팀)

**목적:** 실시간 인터랙션, LLM Wrapper, Cross-Platform 중 하나의 옵션을 선택해 구현하며, 선택한 기술을 실제로 동작하는 형태의 산출물로 완성한다.

**선택 옵션:**

| 옵션 | 설명 |
|---|---|
| 실시간 인터랙션 | 사용자 간 상태 변화, 실시간 데이터 흐름, 스트리밍 응답 등 실시간성이 드러나는 기능을 구현 |
| LLM Wrapper | LLM API를 활용하여 AI 기능이 포함된 산출물을 구현 |
| Cross-Platform | 하나의 산출물을 여러 실행 환경에서 사용할 수 있도록 구현* |

> *데스크톱 앱 ↔ 모바일 앱; 혹은 다른 폼팩터에서의 앱; 웹만/웹 기반 프레임워크(Electron, Tauri 등) 대신 다른 프레임워크를 시도해보는 것을 적극 권장

**결과물:** 선택한 옵션이 적용된 작동 가능한 산출물, 실행 가능한 코드, 시연 자료 및 관련 문서

---

## 팀원

| 이름 | 학교 | GitHub | 역할 |
|---|---|---|---|
| 이재준 |KAIST | dannyiscard | 프런트엔드 |
| 박도현 | GIST | dotori235 | 백엔드 |

---

## 선택 옵션

- [x] 실시간 인터랙션
- [ ] LLM Wrapper
- [x] Cross-Platform

---

## 기획안

- **산출물 주제:** 스플랜더 온라인
- **제작 목적:** 보드게임 스플랜더를 앱을 통해 다른 사람들과 함께 즐길 수 있도록 만드는 것이 목적.
- **선택 옵션:** 
- **핵심 구현 요소:**
  - 스플랜더 멀티플레이 기능
  - MMR 및 리더보드 기능
- **사용 / 시연 시나리오:** 사용자가 어플리케이션에 접속

- **팀원별 역할:**
  - **이재준**: 프런트엔드 설계
  - **박도현**: 백엔드 설계

### 개발 일정

| 날짜 | 목표 |
|---|---|
| Day 1 | 주제 및 프레임워크 선정 |
| Day 2 | 구현명세서, 설계 문서 작성 |
| Day 3 | 멀티플레이, 리더보드 기능 구현 |
| Day 4 |  |
| Day 5 | 프로필, 친구, 설정 기능 구현 |
| Day 6 | 프런트, 백 병합 후 QA 및 수정 |
| Day 7 | 서버 배포 |

---

## 구현 명세서

| 구현 요소 | 설명 | 우선순위 |
|---|---|---|
| 멀티플레이 | 스플랜더를 온라인 상의 다른 사람들과 플레이할 수 있다. 캐주얼 모드와 랭킹전 모드로 나뉜다. | 필수 |
| 리더보드 | 랭킹전의 게임 결과에 따라 MMR이 반영되고, 현재 랭킹을 확인할 수 있다. | 필수 |
| 프로필 | 본인의 프로필과 게임 전적 등을 불러올 수 있다 | 필수 |
| 친구 | 친구 검색/추가/삭제 등 관리 기능과 메시지 기능 |필수|
| 설정 | 음성 설정, 그래픽 설정, 기타 설정, 편의 기능 설정 등 게임 환경에 관한 설정 | 필수 |
| 싱글플레이 | 학습된 AI 모델과 싱글플레이를 할 수 있다 | 선택 |

---

## 아키텍처

<!-- 실시간 인터랙션: WebSocket/SSE/WebRTC 구조도 / LLM Wrapper: API 연동 흐름도 / Cross-Platform: 플랫폼 구성도 -->

---

## 설계 문서

> 프로젝트 성격에 따라 필요한 항목만 작성

### 화면 / 인터페이스 설계

<!-- Figma 링크, 화면 이미지, CLI 사용 예시, 앱 화면 등 -->

### 데이터 구조

<!-- DB 스키마, JSON 구조, 파일 저장 방식 등 -->

### API / 외부 서비스 연동

배포 주소: `https://api.splendor-online.madcamp-kaist.org`

| Endpoint | 설명 | 비고 |
|---|---|---|
| `GET /` | 헬스체크 | 인증 불필요. DB/Redis 둘 다 연결되면 200 `{"status": "ok"}`, 하나라도 안 되면 503 `{"status": "degraded", "db": ..., "redis": ...}` |
| `GET /swagger` | API 문서(Swagger UI) | Basic Auth 필요(`Swagger:Username`/`Swagger:Password`, 배포 환경 값은 팀 채널 참고). `/openapi/v1.json`(원본 스펙)도 동일하게 보호됨 |

## 1. 인증 API (REST)

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| POST | `/auth/register` | 이메일 회원가입 | `{"email": "hong@example.com", "password": "P@ssw0rd123", "nickname": "splendor"}` | `{"userId": "u_1024", "nickname": "스플랜더왕", "provider": "email", "accessToken": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1XzEwMjQifQ.4Q2fA9k1...", "refreshToken": "rtk_3f9a8c2b1d7e4f5a6b7c8d9e0f1a2b3c", "expiresIn": 3600}` | 인증 불필요 |
| POST | `/auth/login` | 이메일 로그인 | `{"email": "hong@example.com", "password": "P@ssw0rd123"}` | `{"userId": "u_1024", "nickname": "스플랜더왕", "provider": "email", "accessToken": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1XzEwMjQifQ.4Q2fA9k1...", "refreshToken": "rtk_3f9a8c2b1d7e4f5a6b7c8d9e0f1a2b3c", "expiresIn": 3600}` | 인증 불필요, 실패 시 401 |
| GET | `/auth/me` | 내 계정 정보 조회 | 없음 | `{"userId": 1024, "email": "hong@example.com", "nickname": "스플랜더왕", "avatarUrl": null, "linkedProviders": ["kakao"], "createdAt": "2026-07-10T09:00:00Z"}` | 인증 필요. 2절 프로필 API와 달리 이메일·연동 계정 등 계정 자체 정보 |

---
## 2. 프로필(Profile) API (REST)

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| GET | `/profile/me` | 내 프로필 조회 | 없음 | `{"userId": 1024, "nickname": "스플랜더왕", "avatarUrl": "/profile/1024/avatar", "totalGamesPlayed": 42, "overallAvgPlace": 2.1, "rankings": [{"playerCount": 3, "rank": 357, "mmr": 1820, "gamesPlayed": 38, "avgPlace": 2.1}], "recentMatches": [{"gameId": 9911, "playerCount": 3, "place": 2, "score": 15, "isRanked": true, "playedAt": "2026-07-10T09:00:00Z"}]}` | 인증 필요. `avatarUrl`은 아바타 미설정 시 `null`, `rankings`는 참가한 인원수별로만 항목이 존재(6. 리더보드 API 참고) |
| GET | `/profile/{userId}` | 다른 유저 프로필 조회 | 없음 | `/profile/me`와 동일 구조 | 인증 필요 |

닉네임/이메일 변경 API는 구현되어 있지 않습니다(가입 시 지정한 닉네임 고정). 유저 검색은 이 절이 아니라 3절의 `GET /friends/search`를 사용합니다.

---

## 3. 친구(Friend) API (REST)

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| GET | `/friends` | 내 친구 목록 조회 | 없음(필터 쿼리 없음, 항상 전체 반환) | `{"friends": [{"userId": 2048, "nickname": "김도현", "avatarUrl": null, "status": "online", "friendsSince": "2026-07-10T09:05:00Z"}]}` | 인증 필요, `status`는 SocialHub 프레즌스와 실시간 연동(`online`\|`offline`\|`in_game`\|`away`) |
| GET | `/friends/search` | 친구 추가용 유저 검색 | Query: `query=스플랜더` (닉네임 부분일치 또는 userId 완전일치) | `{"users": [{"userId": 2048, "nickname": "스플랜더고수", "avatarUrl": null}]}` | 인증 필요, 최대 20건, 본인 제외 |
| POST | `/friends/requests` | 친구 요청 보내기 | `{"targetUserId": 2048}` | `{"requestId": 7788, "userId": 2048, "nickname": "김도현", "avatarUrl": null, "createdAt": "2026-07-10T09:05:00Z"}` | 자기 자신 요청 시 400(`INVALID_PAYLOAD`), 이미 친구면 409(`ALREADY_FRIENDS`), 이미 보낸 요청 있으면 409(`REQUEST_ALREADY_SENT`). 상대가 이미 나에게 요청을 보낸 상태였다면 새로 만들지 않고 즉시 수락 처리되어 `FriendResponse`(위 `/friends` 항목과 동일 구조)가 대신 반환됨 |
| GET | `/friends/requests` | 친구 요청 목록 조회(받은 것 + 보낸 것 함께) | 없음 | `{"incoming": [{"requestId": 7788, "userId": 2048, "nickname": "김도현", "avatarUrl": null, "createdAt": "2026-07-10T09:05:00Z"}], "outgoing": []}` | 인증 필요 |
| POST | `/friends/requests/{requestId}/accept` | 친구 요청 수락 | 없음 | `{"userId": 2048, "nickname": "김도현", "avatarUrl": null, "status": "offline", "friendsSince": "2026-07-10T09:05:00Z"}` | 받은 요청만 수락 가능(아니면 403 `NOT_REQUEST_RECIPIENT`), 양쪽 친구 목록에 상호 등록됨 |
| DELETE | `/friends/requests/{requestId}` | 친구 요청 거절/취소 | 없음 | 204 No Content | 인증 필요. 요청 당사자(보낸 쪽/받은 쪽 둘 다)만 가능(아니면 403 `NOT_REQUEST_PARTICIPANT`) — 받은 쪽이 호출하면 거절(상대에게 `FriendRequestDeclined` push), 보낸 쪽이 호출하면 취소(상대에게 `FriendRequestCancelled` push) |
| DELETE | `/friends/{friendUserId}` | 친구 삭제 | 없음 | 204 No Content | 상호 삭제(양방향), 친구 아니면 404(`NOT_FRIENDS`) |
| GET | `/friends/{userId}/messages` | 친구와의 1:1 채팅 기록 조회 | Query: `beforeId`, `limit`(기본 30, 최대 100, 모두 선택) | `{"messages": [{"messageId": 501, "senderId": 1024, "receiverId": 2048, "body": "오늘 한 판 할래?", "createdAt": "2026-07-10T09:22:00Z"}], "hasMore": false}` | 인증 필요, 친구 아니면 403(`NOT_FRIENDS`). `beforeId` 이전 메시지를 최신순으로 페이지네이션 |
| POST | `/friends/{userId}/messages` | 친구에게 1:1 채팅 전송(REST) | `{"body": "오늘 한 판 할래?"}` | `{"messageId": 501, "senderId": 1024, "receiverId": 2048, "body": "오늘 한 판 할래?", "createdAt": "2026-07-10T09:22:00Z"}` | 인증 필요, 저장 + 상대에게 SocialHub `FriendMessageReceived` push까지 함께 처리(9.1절 `SendFriendMessage` invoke와 동일 로직 공유). 1~1000자, 친구 아니면 403(`NOT_FRIENDS`) |

---
## 4. 방(Room) 관리 API (REST)

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| POST | `/rooms` | 방 생성 | `{"maxPlayers": 4, "isPrivate": false, "password": null}` (`maxPlayers`는 2~4, 기본 4, 나머지 선택) | `{"roomId": "r_5566", "hostId": "u_1024", "status": "WAITING", "maxPlayers": 4, "players": [{"userId": "u_1024", "nickname": "스플랜더왕"}], "createdAt": "2026-07-10T09:10:00Z"}` | 인증 필요, 생성자가 방장. 이 API로 만든 방은 항상 캐주얼 모드이며 클라이언트가 ruleset을 지정할 수 없음. 랭킹전은 별도의 랜덤 매칭 API를 통해 진행 |
| GET | `/rooms` | 방 목록 조회 | Query: `page=1&limit=20` (`limit` 기본 20, 모두 선택) | `{"rooms": [{"roomId": "r_5566", "hostId": "u_1024", "maxPlayers": 4, "players": [{"userId": "u_1024", "nickname": "스플랜더왕"}], "createdAt": "2026-07-10T09:10:00Z"}], "total": 1, "page": 1}` | 인증 필요, 친구 여부와 무관하게 매칭 가능. 대기 중(WAITING)인 방만 반환하므로 목록 항목에는 `status`가 없음 |
| GET | `/rooms/{roomId}` | 방 상세 조회 | 없음 | Room 객체(생성 응답과 동일 구조, 예: `{"roomId": "r_5566", "hostId": "u_1024", "status": "WAITING", "maxPlayers": 4, "players": [...], "createdAt": "2026-07-10T09:10:00Z"}`) | 인증 필요 |
| POST | `/rooms/{roomId}/join` | 방 참가(좌석 예약) | `{"password": "1234"}` (비공개 방일 때만, 그 외엔 `{}`) | 갱신된 Room 객체(생성 응답과 동일 구조) | 인증 필요, 정원/비밀번호 검증(409/403) |
| POST | `/rooms/{roomId}/invites` | 친구를 비공개 방에 초대 | `{"targetUserId": 2048}` | 204 No Content | 인증 필요, 방 멤버만 호출 가능(403 `NOT_A_MEMBER`), 대상은 친구여야 함(403 `NOT_FRIENDS`). 대상에게 GameHub로 `RoomInvite` push(8절), 비공개 방이면 비밀번호 없이 1회 입장 가능한 초대권 발급 |
| POST | `/rooms/{roomId}/leave` | 방 퇴장 | 없음 | 204 No Content | 인증 필요, 방/멤버가 이미 없어도 204(멱등) |
| POST | `/rooms/{roomId}/ready` | 준비 상태 변경 **[신규]** | `{"ready": true}` | 갱신된 Room 객체 | 인증 필요. 캐주얼(일반) 방의 방장이 아닌 멤버 전용 — 방장이 호출하면 400(`HOST_CANNOT_READY`), 방 멤버가 아니면 403(`NOT_A_MEMBER`). 성공 시 방 그룹에 SignalR `PlayerReadyChanged` 브로드캐스트(8절) |
| POST | `/rooms/{roomId}/start` | 게임 시작 | 없음 | `{"gameId": "g_9911", "phase": "PLAYING"}` | 방장만 가능(403). 캐주얼 방은 방장을 제외한 전원이 준비 완료 상태여야 함(아니면 409 `MEMBERS_NOT_READY`) — 랭킹전은 매칭 성사 시 자동 시작이라 이 제약과 무관. 이후 SignalR로 진행 |
| DELETE | `/rooms/{roomId}` | 방 삭제 | 없음 | 204 No Content | 방장만, 시작 전에만 가능(409) |

방 응답의 각 `players[]` 항목은 `{"userId": ..., "nickname": ..., "isHost": ..., "isReady": ...}` 구조입니다(`isReady` **[신규]** — 게임이 끝나고 방이 다시 WAITING으로 돌아가면 전원 초기화됨).

### 4-1. 매칭(Matchmaking) API — 랭킹전 진입

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| POST | `/matchmaking/{playerCount}/ranked` | 랭킹전 대기열 등록 | 없음 (`playerCount`는 `2`\|`3`\|`4`) | `{"status": "QUEUED", "playerCount": 4, "mmr": 1500, "searchRange": 100, "roomId": null}` | 인증 필요. 즉시 방에 들어가지 않고 대기열에 등록됨. 이미 같은 인원수로 대기 중이면 현재 상태를 그대로 반환(멱등), 다른 인원수로 대기 중이면 409(`ALREADY_QUEUED`) |
| DELETE | `/matchmaking/{playerCount}/ranked` | 매칭 대기열 취소 | 없음 | 204 No Content | 인증 필요 |
| GET | `/matchmaking/{playerCount}/status` | 매칭 상태 조회(폴링용) | 없음 | `{"status": "QUEUED"\|"MATCHED"\|"NOT_QUEUED", "playerCount": 4, "mmr": 1500, "searchRange": 180, "roomId": null}` | 인증 필요. 매칭 서버는 2초마다 각 인원수 대기열을 훑어 MMR이 비슷한 유저끼리 묶고(대기시간이 길어질수록 허용 범위가 넓어짐), 정원이 차면 방을 만들어 자동으로 게임을 시작함(SignalR `StateSync` 브로드캐스트). 매칭이 성사되면 대기 중이던 유저에게 SignalR `MatchFound` 이벤트(`{"roomId": ..., "playerCount": ...}`)로 즉시 알리고, 상태 조회로도 확인 가능(`status: "MATCHED"`, 1회 소비 후 사라짐). 이렇게 만들어진 방은 `GET /rooms` 목록과 `POST /rooms/{roomId}/join`으로는 접근 불가(`ROOM_RANKED_ONLY_VIA_MATCHMAKING`) |

---
## 5. 리더보드(Leaderboard) API (REST)

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| GET | `/leaderboard/{playerCount}` | 인원수별 랭킹 목록 조회 | Query: `page=1` (`playerCount`는 `2`\|`3`\|`4`, `page`는 1부터 시작하며 100명 단위로 페이지네이션, 기본 1) | `{"playerCount": 3, "page": 1, "limit": 100, "total": 5820, "entries": [{"rank": 1, "userId": "u_2048", "nickname": "스플랜더고수", "avatarUrl": "https://cdn.splendor-online.com/avatars/u_2048.png", "mmr": 2450, "avgPlace": 1.4, "gamesPlayedSeason": 124}], "myRank": {"rank": 357, "userId": "u_1024", "nickname": "스플랜더왕", "avatarUrl": "https://cdn.splendor-online.com/avatars/u_1024.png", "mmr": 1820, "avgPlace": 2.1, "gamesPlayedSeason": 38}}` | 인증 필요(`myRank` 산출용), `page=1`은 1~100등, `page=2`는 101~200등, `page=3`은 201~300등 … 무한 스크롤 시 `page`를 증가시켜 재호출 |
| GET | `/leaderboard/{playerCount}/search` | 닉네임/유저ID로 랭킹 검색 | Query: `query=스플랜더` (`playerCount`는 `2`\|`3`\|`4`, `query`가 유저ID와 정확히 일치하거나 닉네임에 포함되는 유저를 함께 검색) | `{"playerCount": 3, "query": "스플랜더", "total": 2, "entries": [{"rank": 1, "userId": "u_2048", "nickname": "스플랜더고수", "avatarUrl": "https://cdn.splendor-online.com/avatars/u_2048.png", "mmr": 2450, "avgPlace": 1.4, "gamesPlayedSeason": 124}]}` | 인증 필요, 결과는 `rank` 오름차순, 최대 100건 |

---
## 6. GameHub 메서드 (Client → Server, Flutter `hubConnection.invoke()`)

Hub: `/hubs/game` · 인터페이스: `IGameHub`

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| INVOKE | `JoinRoom` | Hub Group 구독(입장) | `roomId`: `"r_5566"` (string) | 없음(비동기로 `StateSync` full 콜백 수신) | 최초 입장 시 반드시 호출, SocialHub에는 자동으로 `"in_game"` 프레즌스 반영 |
| INVOKE | `LeaveRoom` | Group 탈퇴 | `roomId`: `"r_5566"` (string) | 없음 | |
| INVOKE | `StartGame` | 게임 시작 | `roomId`: `"r_5566"` (string) | 없음(그룹 전체에 `StateSync` 브로드캐스트) | 방장만, 아니면 `HubException` |
| INVOKE | `TakeTokens` | 토큰 획득 | `{"gems": ["diamond", "sapphire", "emerald"]}` (서로 다른 3색 각1 또는 동색 2개) | 없음(브로드캐스트) | 실패 시 `HubException`(`INVALID_TOKEN_SELECTION`) |
| INVOKE | `PurchaseCard` | 카드 구매 | `{"cardId": "c_301", "source": "Board"}` (`source`는 `Board`\|`Reserved`) | 없음(브로드캐스트) | 실패 시 `HubException`(`INSUFFICIENT_COST` 등) |
| INVOKE | `ReserveCard` | 카드 예약 | `{"cardId": "c_301"}` 또는 `{"tier": 2}` (둘 중 하나, `tier`는 `1`\|`2`\|`3`) | 없음(브로드캐스트) | 예약 3장 초과 시 `HubException`(`RESERVE_LIMIT_EXCEEDED`) |
| INVOKE | `DiscardTokens` | 토큰 10개 초과 시 반납 | `{"gems": ["ruby", "onyx"]}` | 없음(브로드캐스트) | 초과분 미반납 시 턴 종료 불가 |
| INVOKE | `ClaimNoble` | 동시 조건 충족 시 귀족 선택 | `nobleId`: `"n_04"` (string) | 없음(브로드캐스트 `NobleAwarded`) | `NobleChoiceRequired` 수신 후에만 유효 |
| INVOKE | `SendChatMessage` | 인게임 채팅 전송 | `{"text": "안녕하세요!"}` | 없음(브로드캐스트 `ChatMessage`) | 서버가 발신자의 친구 목록을 조회해 **같은 방에 있는 친구에게만** 전달(친구 아닌 참가자에게는 미전달) |
| INVOKE | `RequestResync` | 재접속 시 상태 재동기화 | `lastSequence`: `128` (int) | 호출자에게만 `StateSync`(full 또는 delta) 콜백 | 재연결(`onreconnected`) 직후 호출 |

### 6-1. 턴 제한시간 (피셔 룰) **[신규]**

한 턴의 제한시간은 피셔 룰로 관리된다. 클라이언트가 별도로 호출할 API는 없다 — 서버가 마감을 감지해 자동으로 처리하고, 결과는 기존 `StateSync`/`TurnChanged`로 통지된다.

- 각 플레이어는 `timeBankSeconds`(초)를 가지며 초기값 30초, **항상 최대 30초로 캡**된다.
- 자기 턴이 시작되면 서버가 `turnDeadlineUtc`(해당 턴이 끝나는 UTC 시각)를 계산해 `GameState`(`StateSync`)에 실어 보낸다. 클라이언트는 이 값과 로컬 시계로 카운트다운만 표시하면 된다(서버가 authoritative).
- 턴이 끝나는 시점(정상 행동 완료 또는 타임아웃) 공통 공식: `newBank = min(30, remainingAtTurnEnd + 10)`.
- **제한시간 안에 행동하지 못하면 서버가 무조건 턴을 다음 플레이어에게 넘긴다** (별도 클라이언트 요청 불필요). 이때:
  - 귀족 선택 대기 중이었다면 선택을 포기 처리(귀족은 보드에 남아 다음 기회에 재평가됨).
  - **[변경]** 토큰 10개 초과 보유 상태였다면, 정확히 10개가 되도록 초과분을 서버가 무작위로 골라 즉시 은행에 반납시킨다(이전에는 다음 자기 턴까지 그대로 이월됐음).
  - 결과는 `StateSync`와 `TurnChanged`(`reason: "timeout"`)로 방 전체에 브로드캐스트된다.

---
## 7. GameHub 콜백 (Server → Client, Flutter `hubConnection.on()`)

인터페이스: `IGameClient`

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| ON | `StateSync` | 게임 상태 동기화 | - | `{"type": "delta", "state": null, "patch": [{"op": "replace", "path": "/players/0/gems/diamond", "value": 2}], "sequence": 129}` (full일 때는 `state`에 GameState 전체, `patch`는 null) | `patch`는 JSON Patch(RFC6902). **[변경]** full sync의 `state`에 `timeBankSeconds`(플레이어별 다음 턴 예산, 초, ≤30)/`turnDeadlineUtc`(현재 턴 마감 UTC 시각, 게임 종료 시 null) 필드 추가(7-1 참고) |
| ON | `ActionResult` | 직전 호출 처리 결과 | - | `{"success": true, "error": null, "patch": [{"op": "replace", "path": "/players/0/score", "value": 5}]}` | 대부분 `StateSync` delta로 대체 가능(선택 구현) |
| ON | `TurnChanged` | 턴 전환 알림 | - | `{"currentPlayerId": "u_2048", "turnNumber": 4, "reason": "action"}` (`reason`은 `action`\|`timeout`) | **[변경]** `reason` 필드 추가 — `timeout`이면 제한시간 초과로 서버가 자동으로 턴을 넘긴 경우(7-1 참고), UI에서 별도 안내 문구 표시용 |
| ON | `NobleAwarded` | 귀족 타일 자동 획득 | - | `{"playerId": "u_1024", "nobleId": "n_04"}` | |
| ON | `NobleChoiceRequired` | 귀족 동시 충족, 선택 필요 | - | `{"playerId": "u_1024", "candidateNobleIds": ["n_04", "n_07"]}` | `ClaimNoble` 호출 유도 |
| ON | `PlayerJoined` | 방 인원 입장 | - | `{"userId": "u_2048", "nickname": "김도현"}` | |
| ON | `PlayerReadyChanged` | 준비 상태 변경 **[신규]** | - | `{"userId": "u_2048", "ready": true}` | `POST /rooms/{roomId}/ready` 성공 시 방 그룹 전체에 push(4절 참고) |
| ON | `MatchFound` | 랭킹전 매칭 성사 | - | `{"roomId": "r_5566", "playerCount": 4}` | `POST /matchmaking/{n}/ranked`로 대기열에 등록한 유저에게 매칭이 성사되는 즉시 push. 수신 후 `JoinRoom` 호출 |
| ON | `PlayerLeft` | 방 인원 퇴장 | - | `{"userId": "u_2048", "nickname": "김도현"}` | |
| ON | `FinalRoundTriggered` | 15점 달성, 마지막 라운드 진입 | - | `{"triggeredBy": "u_1024", "lastTurnPlayerId": "u_2048"}` | |
| ON | `GameOver` | 게임 종료 | - | `{"winnerId": "u_1024", "finalScores": [{"userId": "u_1024", "score": 16}, {"userId": "u_2048", "score": 13}], "tieBreakReason": null}` | |
| ON | `ChatMessage` | 채팅 수신 | - | `{"playerId": "u_2048", "text": "안녕하세요!", "ts": "2026-07-10T09:21:00Z"}` | **발신자와 친구인 클라이언트에게만** push됨 |
| ON | `EmoteReceived` | 감정표현 수신 | - | `{"playerId": "u_2048", "emoteId": "emote_thumbsup", "ts": "2026-07-10T09:21:05Z"}` | 방 전체 브로드캐스트(친구 제한 없음) |
| ON | `RoomInvite` | 비공개 방 초대 수신 | - | `{"roomId": 5566, "fromUserId": 1024, "fromNickname": "스플랜더왕", "isPrivate": true, "maxPlayers": 4}` | REST `POST /rooms/{roomId}/invites`(4절) 발생 시 대상에게 push |
| ON | `ErrorOccurred` | 비동기 오류 통지 | - | `{"code": "NOT_YOUR_TURN", "message": "현재 당신의 턴이 아닙니다."}` | `invoke()` 예외와 별개(세션 강제종료 등) |
## 8. SocialHub (친구 · 로비 채팅 전용, 신규)

Hub: `/hubs/social` · 인터페이스: `ISocialHub`(Client→Server), `ISocialClient`(Server→Client)

이 Hub는 특정 게임 방(Room)에 종속되지 않고 **로그인 직후부터 앱이 살아있는 동안(로비 포함) 상시 연결을 유지**하며, 친구 프레즌스·요청 알림·친구 간 1:1 채팅을 처리한다. `GameHub`와는 별도 연결이며, 로그아웃 또는 앱 종료 시에만 해제한다.

**[변경]** 동시접속 차단은 이 Hub의 연결 시점에서 강제된다 — 접속 시도 시 같은 계정의 다른 연결이 이미 있으면(`OnConnectedAsync`) 연결 자체를 거부한다(`HubException`(`ALREADY_LOGGED_IN`), 클라이언트의 `connection.start()`가 예외로 실패함). REST `/auth/login`의 `ALREADY_LOGGED_IN` 체크는 신규 로그인만 막을 뿐, 캐시된 accessToken으로 로그인 없이 재연결하는 경로(예: 탭을 닫았다 다시 여는 세션 복원)는 걸러내지 못해 이 Hub 레벨 체크가 추가됐다.

### 8.1 Client → Server

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| INVOKE | `SendFriendMessage` | 친구에게 1:1 채팅 전송(로비/게임 화면 무관) | `{"toUserId": "u_2048", "text": "오늘 한 판 할래?"}` | 없음(상대에게 `FriendMessageReceived` 전달) | 친구 관계 아니면 `HubException`(`NOT_FRIENDS`) |
| INVOKE | `SetPresence` | 내 접속 상태 갱신 | `{"status": "online"}` (`online`\|`away`) | 없음(친구들에게 `FriendStatusChanged` 브로드캐스트) | `GameHub.JoinRoom` 호출 시 서버가 자동으로 `"in_game"`으로 전환, `LeaveRoom` 시 원복 |

### 8.2 Server → Client

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| ON | `FriendRequestReceived` | 친구 요청 수신 | - | `{"requestId": "fr_7788", "fromUserId": "u_2048", "fromNickname": "김도현"}` | REST `POST /friends/requests` 발생 시 실시간 push |
| ON | `FriendRequestAccepted` | 내가 보낸 요청이 수락됨 | - | `{"friendUserId": "u_2048", "friendNickname": "김도현"}` | 요청을 보낸 쪽에 push |
| ON | `FriendRequestDeclined` | 내가 보낸 요청이 거절됨 | - | `{"requestId": "fr_7788", "byUserId": "u_2048"}` | REST `DELETE /friends/requests/{requestId}`를 수신자가 호출했을 때, 요청 보낸 쪽에 push(구현 시 추가된 항목) |
| ON | `FriendRequestCancelled` | 상대가 보낸 요청을 취소함 | - | `{"requestId": "fr_7788", "byUserId": "u_1024"}` | REST `DELETE /friends/requests/{requestId}`를 요청자가 호출했을 때, 수신자 쪽에 push(구현 시 추가된 항목) |
| ON | `FriendRemoved` | 친구가 나를 친구 목록에서 삭제함 | - | `{"byUserId": "u_2048"}` | REST `DELETE /friends/{friendUserId}` 발생 시 상대에게 push(구현 시 추가된 항목) |
| ON | `FriendStatusChanged` | 친구 접속 상태 변경 | - | `{"friendUserId": "u_2048", "status": "online"}` (`online`\|`offline`\|`in_game`\|`away`) | 로비 친구 목록 실시간 갱신용 |
| ON | `FriendMessageReceived` | 친구 1:1 채팅 수신 | - | `{"fromUserId": "u_2048", "text": "오늘 한 판 할래?", "ts": "2026-07-10T09:22:00Z"}` | 로비/게임 어느 화면에서도 수신되므로 앱 전역 리스너로 구독 권장 |

---

## 9. 에러 코드

| Method | Endpoint | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| - | `AUTH_INVALID_TOKEN` | 인증 실패 | - | HTTP 401 또는 `HubException` | 만료/위조 토큰(JWT 미들웨어가 처리, 별도 code 필드 없이 401만 반환) |
| - | `OAUTH_VERIFICATION_FAILED` | 소셜 로그인 토큰 검증 실패 | - | HTTP 401 | 카카오/네이버/구글 API 검증 실패 |
| - | `EMAIL_ALREADY_EXISTS` | 이미 가입된 이메일 | - | HTTP 409 | `/auth/register` |
| - | `ALREADY_LOGGED_IN` | 이미 다른 기기/브라우저에서 로그인 중 | - | HTTP 409(REST 로그인) 또는 `HubException`(SocialHub 연결 시) | `/auth/login`, `/auth/oauth/*`, 그리고 SocialHub `OnConnectedAsync`(캐시된 토큰으로 재연결하는 경로까지 차단, 9절 참고) |
| - | `ALREADY_LINKED` | 이미 다른 계정에 연동된 소셜 계정 | - | HTTP 409 | `/auth/link/{provider}` |
| - | `OAUTH_LOGIN_CONFLICT` | 소셜 최초 로그인 동시 요청 충돌 | - | HTTP 409 | 드묾, 재시도로 해결 |
| - | `USER_NOT_FOUND` | 대상 유저 없음 | - | HTTP 404 | `POST /friends/requests`의 `targetUserId` |
| - | `ROOM_NOT_FOUND` | 방 없음 | - | HTTP 404 | 잘못된 roomId |
| - | `ROOM_FULL` | 방 인원 초과 | - | HTTP 409 | maxPlayers 도달 |
| - | `ROOM_ALREADY_STARTED` | 이미 시작/삭제 불가 상태의 방에 조작 시도 | - | HTTP 409 | join/invites/ready/start/삭제 공통 |
| - | `ROOM_NOT_HOST` | 방장 전용 작업을 비방장이 시도 | - | HTTP 403 | `/rooms/{roomId}/start`, `DELETE /rooms/{roomId}` |
| - | `ROOM_INVALID_PASSWORD` | 비공개 방 비밀번호 불일치 | - | HTTP 403 | `/rooms/{roomId}/join` |
| - | `ROOM_RANKED_ONLY_VIA_MATCHMAKING` | 랭킹전 방에 직접 참가 시도 | - | HTTP 403 | 랭킹전 방은 매칭 API로만 입장 가능 |
| - | `ALREADY_IN_ROOM` | 이미 다른 방에 참가 중 | - | HTTP 409 | 방 생성/참가/매칭 등록 시 |
| - | `TARGET_ALREADY_IN_ROOM` | 초대 대상이 이미 다른 방에 참가 중 | - | HTTP 409 | `/rooms/{roomId}/invites` |
| - | `NOT_A_MEMBER` | 방 멤버가 아닌 유저가 방 전용 작업 시도 | - | HTTP 403 | `/rooms/{roomId}/invites`, `/rooms/{roomId}/ready` |
| - | `NOT_ENOUGH_PLAYERS` | 인원 부족 상태로 시작 시도 | - | HTTP 409 | 최소 2명 필요 |
| - | `HOST_CANNOT_READY` **[신규]** | 방장이 준비 API 호출 | - | HTTP 400 | 방장은 준비 상태가 필요 없음 |
| - | `MEMBERS_NOT_READY` **[신규]** | 미준비 멤버가 있는 상태로 시작 시도 | - | HTTP 409 | 캐주얼 방에서 방장 제외 전원 준비 완료 전엔 `/start` 불가 |
| - | `ALREADY_QUEUED` | 다른 인원수로 이미 매칭 대기 중 | - | HTTP 409 | `/matchmaking/{playerCount}/ranked`, 같은 인원수 재등록은 멱등 처리(4-1절) |
| - | `NOT_YOUR_TURN` | 턴 순서 위반 | - | `HubException` | currentPlayerId 불일치 |
| - | `INVALID_TOKEN_SELECTION` | 토큰 획득 규칙 위반 | - | `HubException` | 3색 미충족/동색 4개 미만 |
| - | `TOKEN_LIMIT_EXCEEDED` | 토큰 10개 초과 | - | `HubException` | 반납 없이 턴 종료 시도 |
| - | `INSUFFICIENT_COST` | 구매 비용 부족 | - | `HubException` | 보석+할인+골드 합 부족 |
| - | `RESERVE_LIMIT_EXCEEDED` | 예약 3장 초과 | - | `HubException` | |
| - | `CARD_NOT_FOUND` | 카드 없음/이미 소비 | - | `HubException` | 잘못된 cardId |
| - | `CARD_NOT_OWNED` | 예약 카드 소유권 불일치 | - | `HubException` | 타인의 예약 카드 구매 시도 |
| - | `NOBLE_NOT_ELIGIBLE` | 귀족 조건 미충족 | - | `HubException` | 임의 nobleId 요청 |
| - | `EMOTE_INVALID` | 정의되지 않은 emoteId | - | `HubException` | 10.4 목록에 없는 값 |
| - | `NOT_FRIENDS` | 친구 아닌 대상에게 DM/채팅/초대/기록조회 시도 | - | HTTP 403 / `HubException` | REST(`/friends/{userId}/messages`, `/rooms/{roomId}/invites`) 와 `SendFriendMessage` invoke, 인게임 채팅 필터링 시에도 사용 |
| - | `ALREADY_FRIENDS` | 이미 친구인 상대에게 요청 | - | HTTP 409 | `POST /friends/requests` |
| - | `REQUEST_ALREADY_SENT` | 이미 보낸 친구 요청 중복 전송 | - | HTTP 409 | `POST /friends/requests` |
| - | `REQUEST_NOT_FOUND` | 잘못된 requestId로 수락 시도 | - | HTTP 404 | `POST /friends/requests/{requestId}/accept` (`DELETE`는 없으면 조용히 204) |
| - | `REQUEST_ALREADY_RESOLVED` | 이미 수락/거절/취소된 요청 재처리 시도 | - | HTTP 409 | accept, `DELETE /friends/requests/{requestId}` |
| - | `NOT_REQUEST_RECIPIENT` | 받은 사람이 아닌 유저가 요청 수락 시도 | - | HTTP 403 | `POST /friends/requests/{requestId}/accept` |
| - | `NOT_REQUEST_PARTICIPANT` | 요청 당사자가 아닌 유저가 거절/취소 시도 | - | HTTP 403 | `DELETE /friends/requests/{requestId}` |
| - | `INVALID_PAYLOAD` | 스키마 검증 실패 | - | HTTP 400 / `HubException` | 필드 누락/타입 오류, 아바타 업로드 형식 오류 포함 |
| - | `RATE_LIMITED` | 요청 과다 | - | HTTP 429 / `HubException` | |
| - | `INTERNAL_ERROR` | 서버 내부 오류 | - | HTTP 500 | |
---

## 산출물 및 실행 방법

- **산출물 설명:** 스플랜더 기반 보드게임 온라인 멀티플레이 플랫폼
- **실행 환경:**
  - 윈도우: https://drive.google.com/file/d/1Aim3u95zTP9AuJgoZBJq6Y1WF0Aqu9-n/view?usp=sharing
  - 안드로이드: https://drive.google.com/file/d/1ew8ODyt5HHJdWDA6_6KELunYTourY-lX/view?usp=sharing
- **실행 방법:**
  - 윈도우: 설치 후 .exe파일 실행
  - 안드로이드: 보안 관련 경고 무시 후 설치
- **시연 영상 / 이미지:** (선택)

### 기술 구성

| 분류 | 사용 기술 |
|---|---|
| 핵심 기술 | ASP.NET + SignalR |
| 실행 환경 | Flutter + Flame |
| 데이터 저장 | PostegreSQL |
| 외부 API / 서비스 | 없음 |
| 기타 |  |

---

## 회고 문서

> [KPT 방법론 참고](https://velog.io/@habwa/%EB%8B%A8%EA%B8%B0-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%ED%9A%8C%EA%B3%A0-KPT-%EB%B0%A9%EB%B2%95%EB%A1%A0)

### Keep — 잘 된 점, 다음에도 유지할 것

-  QA 진행하면서 개선점이나 버그를 공유 문서로 관리하여 문제 해결에 도움이 됨
-  피드백을 적극적으로 공유하고 반영함
-  

### Problem — 아쉬웠던 점, 개선이 필요한 것

-  브랜치 관리가 잘 안돼서 충돌이 일어남
-  ReadMe 파일을 따르지 않은 경우가 있어 실제 구현과 ReadMe가 다른 경우가 있었음
-  프론트엔드에 대한 충분한 이해 없이 AI를 활용하여 코딩하다보니, 프론트엔드 구조 내 정보의 흐름 등을 이해하지 못하다가 결국 AI에게 맡겨버린 경우가 많았음

### Try — 다음번에 시도해볼 것

-  다음에는 브랜치 관리 기법을 참고하여 레포지토리 관리
-  ReadMe파일을 더 철저하게 참조하도록 명심
-  본인이 잘 모르는 분야라면 어느정도 기초 지식을 쌓은 뒤에 구현에 임하는 게 좋을 것 같음

### 팀원별 소감

**이재준:**

> 게임을 만들어 본 게 처음인데, 이렇게 신경써야 할 것이 많았을 줄은 몰랐다. 와이어프레임 작성부터 제 처참한 디자인 감각에 좌절했었고, 화면을 실제로 구현하는 것은 기존의 백엔드 구현과 느낌이 많이 달랐다. 또한 프론트엔드가 처음이기도 했고, 구현하면서 AI를 활용하다 보니 어느 순간부터 단일 함수의 원리 뿐만 아니라 프론트 구조 내 정보의 흐름도 놓치게 된 것 같아 많이 아쉽다. 그래도 게임 앱을 만들어보면서 게임 개발에 대한 지식을 어느정도 습득할 수 있어서 좋았다.
**박도현:**

> 

---

## 참고 자료

### 실시간 인터랙션

**WebSocket**
- https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API
- https://techblog.woowahan.com/5268/
- https://tech.kakao.com/posts/391
- https://daleseo.com/websocket/
- https://kakaoentertainment-tech.tistory.com/110

**Socket.IO**
- https://socket.io/docs/v4/
- https://inpa.tistory.com/entry/SOCKET-%F0%9F%93%9A-Namespace-Room-%EA%B8%B0%EB%8A%A5
- https://adjh54.tistory.com/549
- https://fred16157.github.io/node.js/nodejs-socketio-communication-room-and-namespace/

**SSE (Server-Sent Events)**
- https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events
- https://developer.mozilla.org/ko/docs/Web/API/Server-sent_events/Using_server-sent_events
- https://api7.ai/ko/blog/what-is-sse

**TCP / UDP Socket**
- https://docs.python.org/3/library/socket.html
- https://inpa.tistory.com/entry/NW-%F0%9F%8C%90-%EC%95%84%EC%A7%81%EB%8F%84-%EB%AA%A8%ED%98%B8%ED%95%9C-TCP-UDP-%EA%B0%9C%EB%85%90-%E2%9D%93-%EC%89%BD%EA%B2%8C-%EC%9D%B4%ED%95%B4%ED%95%98%EC%9E%90

**gRPC Streaming**
- https://grpc.io/docs/what-is-grpc/core-concepts/
- https://tech.ktcloud.com/entry/gRPC%EC%9D%98-%EB%82%B4%EB%B6%80-%EA%B5%AC%EC%A1%B0-%ED%8C%8C%ED%97%A4%EC%B9%98%EA%B8%B0-HTTP2-Protobuf-%EA%B7%B8%EB%A6%AC%EA%B3%A0-%EC%8A%A4%ED%8A%B8%EB%A6%AC%EB%B0%8D
- https://tech.ktcloud.com/entry/gRPC%EC%9D%98-%EB%82%B4%EB%B6%80-%EA%B5%AC%EC%A1%B0-%ED%8C%8C%ED%97%A4%EC%B9%98%EA%B8%B02-Channel-Stub
- https://inspirit941.tistory.com/371
- https://devocean.sk.com/blog/techBoardDetail.do?ID=167433

**WebRTC**
- https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API
- https://webrtc.org/getting-started/overview
- https://web.dev/articles/webrtc-basics?hl=ko
- https://devocean.sk.com/blog/techBoardDetail.do?ID=164885
- https://beomkey-nkb.github.io/%EA%B0%9C%EB%85%90%EC%A0%95%EB%A6%AC/webRTC%EC%A0%95%EB%A6%AC/
- https://gh402.tistory.com/45
- https://on.com2us.com/tech/webrtc-coturn-turn-stun-server-setup-guide/

**QUIC / WebTransport**
- https://developer.mozilla.org/en-US/docs/Web/API/WebTransport_API
- https://datatracker.ietf.org/doc/html/rfc9000
- https://news.hada.io/topic?id=13888

#### KCLOUD VM / Cloudflare Tunnel 환경별 주의사항

| 환경 | 사용 가능(권장) 기술 | 포트/조건 | 주의할 기술 |
|---|---|---|---|
| **로컬 / 일반 VM** | HTTP/REST, WebSocket, Socket.IO, SSE, TCP Socket, gRPC Streaming, WebRTC, QUIC/WebTransport 등 대부분 가능 | 직접 포트 개방 가능. 예: 3000, 5000, 8000, 8080, 9000 등. 외부 공개 시 방화벽/보안그룹/공인 IP 설정 필요 | WebRTC는 STUN/TURN 필요 가능. QUIC/WebTransport는 HTTP/3 · UDP 지원 필요 |
| **KCLOUD VM (VPN 내부)** | HTTP/REST, WebSocket, Socket.IO, SSE, WebRTC 시그널링 | 접속 기기 VPN 필요. 기본 허용 포트: **22, 80, 443**. 개발 포트(3000, 8000, 8080 등)는 직접 접근 제한 가능 | TCP Socket은 포트 제한 있음. gRPC는 HTTP/2 설정 필요. WebRTC 미디어·UDP·QUIC/WebTransport 비권장 |
| **KCLOUD VM + Tunnel** | HTTP/REST, WebSocket, Socket.IO, SSE, WebRTC 시그널링 | VM의 `localhost:<port>`를 도메인에 연결. `localPort`는 **1024~65535**. 예: 3000, 8000, 8080 가능 | 순수 TCP Socket, UDP, WebRTC 미디어/DataChannel, QUIC/WebTransport 불가. gRPC 보장 어려움 |
| **외부 서비스 + 우리 도메인** | HTTP/REST, WebSocket, Socket.IO, SSE, WebRTC 시그널링 | Vercel/Netlify/Railway/Render/AWS/GCP 등에 배포 후 CNAME/A 레코드 연결. 보통 외부는 **443** 사용 | WebSocket/gRPC/TCP/UDP는 플랫폼 지원 여부 확인 필요. 서버리스 플랫폼은 장시간 연결 제한 가능 |
| **서버 없이 외부 SaaS 사용** | Supabase Realtime, Firebase, Pusher/Ably, LLM API Streaming | 직접 포트 관리 불필요. 각 서비스 SDK/API 사용 | 커스텀 TCP/UDP 서버 구현 불가. WebRTC는 STUN/TURN 필요할 수 있음 |

### LLM Wrapper

- https://github.com/teddylee777/openai-api-kr
- https://github.com/teddylee777/langchain-kr
- https://devocean.sk.com/blog/techBoardDetail.do?ID=167407
- https://mastra.ai/docs

### Cross-Platform

- https://flutter.dev/
- https://reactnative.dev/
- https://docs.expo.dev/
- https://kotlinlang.org/multiplatform/
