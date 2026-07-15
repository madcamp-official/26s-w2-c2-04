import { useEffect, useMemo, useRef, useState } from "react";
import {
  Check, ChevronLeft, Crown, Lock, MessageCircle, Plus, Search, Settings, Shield,
  Trophy, User, UserPlus, Users, X, Swords, LogIn, Shuffle, Sparkles,
  CircleDot, Send, Trash2,
} from "lucide-react";

// ── constants ─────────────────────────────────────────────────────────────────

const FRIENDS = [
  { name: "루비사냥꾼", status: "in game", tone: "bg-[#762034]" },
  { name: "김도현",     status: "online",  tone: "bg-[#1b7058]" },
  { name: "Mira",       status: "online",  tone: "bg-[#315786]" },
  { name: "도시의상인", status: "offline", tone: "bg-[#4e4655]" },
] as const;

type Friend = typeof FRIENDS[number];

const SEED_MESSAGES: Record<string, { text: string; mine: boolean }[]> = {
  "루비사냥꾼": [
    { text: "야 스플렌더 한판?", mine: false },
    { text: "ㅇㅇ 대기중이야", mine: true },
    { text: "들어와 방 팠음", mine: false },
  ],
  "김도현": [
    { text: "어제 리더보드 올라갔더라", mine: false },
    { text: "진짜? 나도 봤어 대박", mine: true },
  ],
};

const rooms = [
  ["Medici's Counting House", "2 / 2", "Playing", true],
  ["Sapphire Salon", "1 / 3", "Waiting", false],
  ["The Venetian Guild", "3 / 4", "Waiting", false],
  ["House of Rubies", "2 / 2", "Playing", true],
  ["Midnight Bazaar", "1 / 2", "Waiting", false],
  ["Emerald Ledger", "2 / 3", "Waiting", false],
  ["The Florentine Table", "3 / 4", "Waiting", false],
  ["Gilded Reserve", "1 / 4", "Waiting", false],
  ["Crown & Carat", "2 / 3", "Waiting", false],
  ["Blue Stone Parlour", "1 / 2", "Waiting", false],
];

const rankingNames = ["Aurelius","루비의연금술사","VENETIAN_7","보석감정사","DuchessM","에메랄드왕","Cardinal Red","비단상인","SapphireFox","골드러시","Lorenzo","진주상회"];

// ── tiny helpers ──────────────────────────────────────────────────────────────

const avatar = (name: string, tone = "bg-emerald-900") => (
  <div className={`grid h-10 w-10 shrink-0 place-items-center rounded-full border border-[#d2ae55]/45 ${tone} font-['Cinzel'] text-sm text-[#f8e8bb]`}>
    {name.slice(0, 1)}
  </div>
);

function GemParticles() {
  const gems = useMemo(() => Array.from({ length: 28 }, (_, i) => ({
    id: i, left: `${(i * 37) % 100}%`, top: `${(i * 71) % 100}%`, size: 5 + (i % 4) * 3,
    color: ["#bd3045","#2f9c74","#357fc7","#8d58a1","#d2ae55"][i % 5],
    delay: `${i * -0.73}s`, duration: `${8 + (i % 5) * 2}s`,
  })), []);
  return <>{gems.map((g) => (
    <span key={g.id} className="absolute animate-[float_12s_ease-in-out_infinite] rotate-45 rounded-[2px]"
      style={{ left: g.left, top: g.top, width: g.size, height: g.size, background: g.color, opacity: .35, animationDelay: g.delay, animationDuration: g.duration, boxShadow: `0 0 13px ${g.color}` }} />
  ))}</>;
}

function OrnateTitle({ children, kicker }: { children: React.ReactNode; kicker?: string }) {
  return (
    <div className="text-center">
      {kicker && <p className="mb-2 font-['Lato'] text-[10px] uppercase tracking-[.3em] text-[#d2ae55]/65">{kicker}</p>}
      <h2 className="font-['Cinzel'] text-2xl font-semibold tracking-[.06em] text-[#f4dfaa]">{children}</h2>
      <div className="mt-3 flex items-center justify-center gap-3 text-[#d2ae55]/55">
        <span className="h-px w-12 bg-current" /><Sparkles size={13} /><span className="h-px w-12 bg-current" />
      </div>
    </div>
  );
}

// Frame: always centered for non-side, side-panel for side
function Frame({ children, onClose, wide = false, side = false }: { children: React.ReactNode; onClose: () => void; wide?: boolean; side?: boolean }) {
  return (
    <div
      className={`fixed inset-0 z-50 flex bg-[#030205]/75 p-4 backdrop-blur-sm ${side ? "justify-end" : "items-center justify-center"}`}
      onMouseDown={onClose}
    >
      <section
        onMouseDown={(e) => e.stopPropagation()}
        className={`${side ? "h-full w-full max-w-md" : `${wide ? "max-w-5xl" : "max-w-2xl"} max-h-[90vh] w-full`} relative overflow-hidden border border-[#d2ae55]/35 bg-[#100b13]/95 shadow-[0_0_80px_rgba(0,0,0,.7)]`}
      >
        <div className="pointer-events-none absolute inset-2 border border-[#d2ae55]/10" />
        <button onClick={onClose} aria-label="닫기" className="absolute right-5 top-5 z-10 grid h-9 w-9 place-items-center border border-[#d2ae55]/30 text-[#d2ae55] transition hover:bg-[#d2ae55]/10">
          <X size={18} />
        </button>
        <div className="relative max-h-[90vh] overflow-y-auto p-8 [scrollbar-width:thin]">{children}</div>
      </section>
    </div>
  );
}

function UtilityButton({ icon: Icon, label, onClick }: { icon: typeof User; label: string; onClick: () => void }) {
  return (
    <button onClick={onClick} aria-label={label} title={label} className="grid h-10 w-10 place-items-center border border-[#d2ae55]/30 bg-[#130d19]/80 text-[#d2ae55]/80 transition hover:border-[#d2ae55]/70 hover:bg-[#d2ae55]/10">
      <Icon size={17} />
    </button>
  );
}

// ── friends panel sub-components ──────────────────────────────────────────────

type CtxMenu = { x: number; y: number; friend: Friend } | null;

function FriendRow({ friend, onCtx }: { friend: Friend; onCtx: (e: React.MouseEvent, f: Friend) => void }) {
  const { name, status, tone } = friend;
  const statusColor = status === "in game" ? "text-[#d2ae55]" : status === "online" ? "text-[#71c598]" : "text-[#b3a68d]/50";
  return (
    <button
      onClick={(e) => onCtx(e, friend)}
      className="flex w-full items-center gap-3 border border-[#d2ae55]/12 px-3 py-3 text-left transition hover:bg-[#d2ae55]/[.06] focus:outline-none"
    >
      {avatar(name, tone)}
      <div className="min-w-0 flex-1">
        <p className="font-['Lato'] text-sm text-[#f0dfbb]">{name}</p>
        <p className={`mt-0.5 font-['Lato'] text-[10px] uppercase tracking-[.12em] ${statusColor}`}>{status}</p>
      </div>
      <Trash2 size={13} className="shrink-0 text-[#d2ae55]/25 hover:text-[#bb4856]" onClick={(e) => e.stopPropagation()} />
    </button>
  );
}

function ContextMenu({ ctx, onProfile, onMessage, onClose }: {
  ctx: NonNullable<CtxMenu>;
  onProfile: () => void;
  onMessage: () => void;
  onClose: () => void;
}) {
  return (
    <>
      <div className="fixed inset-0 z-[80]" onMouseDown={onClose} />
      <div
        className="fixed z-[81] min-w-[148px] border border-[#d2ae55]/40 bg-[#110c16]/97 shadow-[0_8px_32px_rgba(0,0,0,.7)] backdrop-blur-sm"
        style={{ left: ctx.x, top: ctx.y }}
        onMouseDown={(e) => e.stopPropagation()}
      >
        <div className="pointer-events-none absolute inset-[1px] border border-[#d2ae55]/10" />
        {[
          { label: "프로필 보기", icon: User, action: onProfile },
          { label: "메시지 보내기", icon: MessageCircle, action: onMessage },
        ].map(({ label, icon: Icon, action }) => (
          <button
            key={label}
            onClick={() => { action(); onClose(); }}
            className="flex w-full items-center gap-2.5 px-4 py-2.5 font-['Lato'] text-xs text-[#f0dfbb] transition hover:bg-[#d2ae55]/10"
          >
            <Icon size={13} className="text-[#d2ae55]/70" />
            {label}
          </button>
        ))}
      </div>
    </>
  );
}

function FriendProfilePopup({ friend, onClose }: { friend: Friend; onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-[90] flex items-center justify-center bg-[#030205]/60 backdrop-blur-sm p-4" onMouseDown={onClose}>
      <section onMouseDown={(e) => e.stopPropagation()} className="relative w-full max-w-sm overflow-hidden border border-[#d2ae55]/35 bg-[#100b13]/97 shadow-[0_0_60px_rgba(0,0,0,.8)]">
        <div className="pointer-events-none absolute inset-2 border border-[#d2ae55]/10" />
        <button onClick={onClose} className="absolute right-4 top-4 z-10 grid h-8 w-8 place-items-center border border-[#d2ae55]/30 text-[#d2ae55] hover:bg-[#d2ae55]/10"><X size={16} /></button>
        <div className="p-7">
          <p className="mb-2 font-['Lato'] text-[10px] uppercase tracking-[.3em] text-[#d2ae55]/55">Merchant profile</p>
          <div className="flex items-center gap-4 border-b border-[#d2ae55]/15 pb-5">
            {avatar(friend.name, friend.tone)}
            <div>
              <p className="font-['Cinzel'] text-base text-[#f3e2bb]">{friend.name}</p>
              <p className={`mt-1 font-['Lato'] text-[10px] uppercase tracking-[.12em] ${friend.status === "in game" ? "text-[#d2ae55]" : friend.status === "online" ? "text-[#71c598]" : "text-[#b3a68d]/50"}`}>{friend.status}</p>
            </div>
          </div>
          <div className="mt-5 grid grid-cols-3 gap-px bg-[#d2ae55]/15">
            <Stat label="Games" value="31" /><Stat label="Wins" value="18" /><Stat label="Avg score" value="13.2" />
          </div>
          <div className="mt-5 space-y-2">
            {[["2 Players","#344","1640 MMR"],["3 Players","#129","1890 MMR"]].map(r => (
              <div key={r[0]} className="flex justify-between border border-[#d2ae55]/12 px-3 py-2 font-['Lato'] text-xs">
                <span className="text-[#f0dfbb]">{r[0]}</span>
                <span className="text-[#d2ae55]">{r[1]} · {r[2]}</span>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

function ChatPanel({ friend, history, onSend, onClose }: {
  friend: Friend;
  history: { text: string; mine: boolean }[];
  onSend: (text: string) => void;
  onClose: () => void;
}) {
  const [draft, setDraft] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);

  const submit = () => {
    const t = draft.trim();
    if (!t) return;
    onSend(t);
    setDraft("");
    setTimeout(() => bottomRef.current?.scrollIntoView({ behavior: "smooth" }), 30);
  };

  return (
    <section
      onMouseDown={(e) => e.stopPropagation()}
      className="relative flex h-full w-80 shrink-0 flex-col border-r border-[#d2ae55]/25 bg-[#0c0810]/97"
    >
      {/* header */}
      <div className="flex items-center gap-3 border-b border-[#d2ae55]/20 px-5 py-4">
        {avatar(friend.name, friend.tone)}
        <div className="flex-1 min-w-0">
          <p className="font-['Cinzel'] text-sm text-[#f4dfaa] truncate">{friend.name}</p>
          <p className="font-['Lato'] text-[10px] uppercase tracking-[.1em] text-[#d2ae55]/55">{friend.status}</p>
        </div>
        <button onClick={onClose} className="grid h-7 w-7 shrink-0 place-items-center border border-[#d2ae55]/25 text-[#d2ae55]/60 hover:bg-[#d2ae55]/10">
          <X size={14} />
        </button>
      </div>

      {/* messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3 [scrollbar-width:thin]">
        {history.length === 0 && (
          <p className="text-center font-['Lato'] text-xs text-[#d2ae55]/35 mt-8">대화를 시작해보세요</p>
        )}
        {history.map((msg, i) => (
          <div key={i} className={`flex ${msg.mine ? "justify-end" : "justify-start"}`}>
            <div
              className={`max-w-[80%] px-3 py-2 font-['Lato'] text-sm leading-relaxed ${
                msg.mine
                  ? "bg-[#d2ae55]/20 text-[#f4dfaa] border border-[#d2ae55]/30"
                  : "bg-[#1e1228]/80 text-[#f0dfbb] border border-[#d2ae55]/12"
              }`}
            >
              {msg.text}
            </div>
          </div>
        ))}
        <div ref={bottomRef} />
      </div>

      {/* input */}
      <div className="border-t border-[#d2ae55]/20 px-3 py-3 flex gap-2">
        <input
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); submit(); }}}
          placeholder="메시지 입력…"
          className="input flex-1 text-sm"
        />
        <button
          onClick={submit}
          className="grid h-10 w-10 shrink-0 place-items-center border border-[#d2ae55]/45 text-[#d2ae55] transition hover:bg-[#d2ae55]/15"
        >
          <Send size={15} />
        </button>
      </div>
    </section>
  );
}

function FriendsOverlay({ onClose }: { onClose: () => void }) {
  const [ctxMenu, setCtxMenu] = useState<CtxMenu>(null);
  const [chatFriend, setChatFriend] = useState<Friend | null>(null);
  const [friendProfile, setFriendProfile] = useState<Friend | null>(null);
  const [chatHistory, setChatHistory] = useState<Record<string, { text: string; mine: boolean }[]>>(SEED_MESSAGES);

  const onCtx = (e: React.MouseEvent, f: Friend) => {
    e.stopPropagation();
    const margin = 8;
    const menuW = 152, menuH = 80;
    let x = e.clientX + margin;
    let y = e.clientY + margin;
    if (x + menuW > window.innerWidth) x = e.clientX - menuW - margin;
    if (y + menuH > window.innerHeight) y = e.clientY - menuH - margin;
    setCtxMenu({ x, y, friend: f });
  };

  const sendMessage = (text: string) => {
    if (!chatFriend) return;
    setChatHistory((prev) => ({
      ...prev,
      [chatFriend.name]: [...(prev[chatFriend.name] ?? []), { text, mine: true }],
    }));
  };

  const onlineFriends = FRIENDS.filter((f) => f.status !== "offline")
    .sort((a, b) => (a.status === "in game" ? -1 : b.status === "in game" ? 1 : 0));
  const offlineFriends = FRIENDS.filter((f) => f.status === "offline");

  return (
    <>
      {/* backdrop */}
      <div
        className="fixed inset-0 z-50 flex justify-end bg-[#030205]/75 backdrop-blur-sm"
        onMouseDown={() => { onClose(); setChatFriend(null); setCtxMenu(null); }}
      >
        {/* chat panel — left of friends panel */}
        {chatFriend && (
          <ChatPanel
            friend={chatFriend}
            history={chatHistory[chatFriend.name] ?? []}
            onSend={sendMessage}
            onClose={() => setChatFriend(null)}
          />
        )}

        {/* friends panel */}
        <section
          onMouseDown={(e) => e.stopPropagation()}
          className="relative h-full w-full max-w-sm overflow-hidden border-l border-[#d2ae55]/35 bg-[#100b13]/95 shadow-[-8px_0_40px_rgba(0,0,0,.5)]"
        >
          <div className="pointer-events-none absolute inset-2 border border-[#d2ae55]/10" />
          <button onClick={onClose} aria-label="닫기" className="absolute right-5 top-5 z-10 grid h-9 w-9 place-items-center border border-[#d2ae55]/30 text-[#d2ae55] transition hover:bg-[#d2ae55]/10">
            <X size={18} />
          </button>
          <div className="h-full overflow-y-auto p-8 [scrollbar-width:thin]">
            <OrnateTitle kicker="Social hub">Friends</OrnateTitle>

            <div className="relative mt-7">
              <Search className="absolute left-3 top-3 text-[#d2ae55]/55" size={16} />
              <input placeholder="Find by nickname" className="input pl-10" />
            </div>
            <button className="mt-3 flex w-full items-center justify-center gap-2 border border-[#d2ae55]/45 py-3 font-['Cinzel'] text-xs tracking-[.13em] text-[#d2ae55] hover:bg-[#d2ae55]/10">
              <UserPlus size={15} /> ADD A FRIEND
            </button>

            {/* ONLINE section */}
            <section className="mt-8">
              <div className="mb-3 flex items-center justify-between">
                <h3 className="font-['Cinzel'] text-xs uppercase tracking-[.15em] text-[#71c598]/80">Online <span className="text-[#71c598]/45">— {onlineFriends.length}</span></h3>
              </div>
              <div className="space-y-1.5">
                {onlineFriends.map((f) => (
                  <FriendRow key={f.name} friend={f} onCtx={onCtx} />
                ))}
              </div>
            </section>

            {/* OFFLINE section */}
            {offlineFriends.length > 0 && (
              <section className="mt-6">
                <div className="mb-3 flex items-center gap-2">
                  <h3 className="font-['Cinzel'] text-xs uppercase tracking-[.15em] text-[#d2ae55]/35">Offline <span className="text-[#d2ae55]/20">— {offlineFriends.length}</span></h3>
                  <div className="flex-1 h-px bg-[#d2ae55]/10" />
                </div>
                <div className="space-y-1.5">
                  {offlineFriends.map((f) => (
                    <FriendRow key={f.name} friend={f} onCtx={onCtx} />
                  ))}
                </div>
              </section>
            )}

            {/* Requests */}
            <section className="mt-8 border-t border-[#d2ae55]/20 pt-5">
              <h3 className="font-['Cinzel'] text-sm tracking-[.12em] text-[#e9d4a4]">REQUESTS <span className="text-[#d2ae55]/55">01</span></h3>
              <div className="mt-3 flex items-center gap-3 border border-[#d2ae55]/15 px-3 py-3">
                {avatar("은", "bg-[#80582a]")}
                <span className="flex-1 font-['Lato'] text-sm">은빛상인</span>
                <button className="grid h-7 w-7 place-items-center border border-[#5fb884]/50 text-[#75d09a]"><Check size={15} /></button>
                <button className="grid h-7 w-7 place-items-center border border-[#b94c5b]/50 text-[#e3737f]"><X size={15} /></button>
              </div>
            </section>
          </div>
        </section>
      </div>

      {/* context menu */}
      {ctxMenu && (
        <ContextMenu
          ctx={ctxMenu}
          onClose={() => setCtxMenu(null)}
          onProfile={() => { setFriendProfile(ctxMenu.friend); setCtxMenu(null); }}
          onMessage={() => { setChatFriend(ctxMenu.friend); setCtxMenu(null); }}
        />
      )}

      {/* friend profile popup (centered) */}
      {friendProfile && (
        <FriendProfilePopup friend={friendProfile} onClose={() => setFriendProfile(null)} />
      )}
    </>
  );
}

// ── main app ──────────────────────────────────────────────────────────────────

function App() {
  const [layer, setLayer] = useState<"setup"|"rooms"|"create"|"lobby"|"matching"|"leaderboard"|"profile"|"friends"|null>(null);
  const [mode, setMode] = useState<"normal"|"ranked"|null>(null);
  const [method, setMethod] = useState<"random"|"create"|"join"|null>(null);
  const [players, setPlayers] = useState<number|null>(null);
  const [rankPlayers, setRankPlayers] = useState(2);
  const [query, setQuery] = useState("");
  const [ready, setReady] = useState(false);
  const [roomName, setRoomName] = useState("새로운 보석 상회");
  const [password, setPassword] = useState(false);

  const resetSetup = () => { setMode(null); setMethod(null); setPlayers(null); setLayer(null); };
  const selectedComplete = mode === "ranked" ? !!players : !!method && !!players;
  const switchLayer = (next: typeof layer) => setLayer(next);

  return (
    <main className="relative min-h-screen overflow-hidden bg-[#08050a] text-[#f5ead4] selection:bg-[#d2ae55] selection:text-[#130d19]">
      <style>{`@keyframes float { 0%,100%{transform:translateY(0) rotate(45deg)} 50%{transform:translateY(-28px) rotate(225deg)} }`}</style>
      <GemParticles />
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,rgba(66,28,54,.42),transparent_53%),radial-gradient(ellipse_at_72%_23%,rgba(25,77,64,.18),transparent_26%)]" />
      <div className="pointer-events-none absolute left-8 top-8 h-36 w-36 border-l border-t border-[#d2ae55]/25" />
      <div className="pointer-events-none absolute bottom-8 right-8 h-36 w-36 border-b border-r border-[#d2ae55]/25" />

      <div className="absolute bottom-6 right-6 z-10 flex gap-2">
        <UtilityButton icon={User}     label="Profile"  onClick={() => setLayer("profile")}  />
        <UtilityButton icon={UserPlus} label="Friends"  onClick={() => setLayer("friends")}  />
        <UtilityButton icon={Settings} label="Settings" onClick={() => {}}                   />
      </div>

      {/* lobby */}
      <section className="relative z-[1] flex min-h-screen flex-col items-center justify-center px-5 pb-8 pt-16 text-center">
        <p className="mb-4 font-['Lato'] text-[10px] uppercase tracking-[.5em] text-[#d2ae55]/70">The guild of gem merchants</p>
        <h1 className="font-['Cinzel'] text-5xl font-black tracking-[.1em] text-[#f6e6bd] sm:text-7xl">SPLENDOR</h1>
        <div className="mt-5 flex items-center gap-3 text-[#d2ae55]"><span className="h-px w-16 bg-current" /><Crown size={18} /><span className="h-px w-16 bg-current" /></div>
        <p className="mt-5 max-w-sm font-['Lato'] text-sm tracking-[.08em] text-[#dac9a9]/70">Gather your patrons. Build a legacy in precious stones.</p>
        <div className="mt-12 flex flex-col gap-4 sm:flex-row">
          <button onClick={() => setLayer("setup")} className="group min-w-56 border border-[#d2ae55]/60 bg-[#d2ae55]/10 px-8 py-5 transition hover:-translate-y-1 hover:bg-[#d2ae55]/20 hover:shadow-[0_10px_35px_rgba(210,174,85,.2)]">
            <Swords className="mx-auto mb-2 text-[#d2ae55]" size={23} />
            <span className="font-['Cinzel'] text-base tracking-[.13em] text-[#f6e6bd]">MULTIPLAYER</span>
            <small className="mt-1 block font-['Lato'] text-[10px] tracking-[.16em] text-[#d2ae55]/70">ENTER THE MARKET</small>
          </button>
          <button onClick={() => setLayer("leaderboard")} className="group min-w-56 border border-[#d2ae55]/35 bg-[#130d19]/70 px-8 py-5 transition hover:-translate-y-1 hover:border-[#d2ae55]/70 hover:bg-[#d2ae55]/10">
            <Trophy className="mx-auto mb-2 text-[#76a7d9]" size={23} />
            <span className="font-['Cinzel'] text-base tracking-[.13em] text-[#f6e6bd]">LEADERBOARD</span>
            <small className="mt-1 block font-['Lato'] text-[10px] tracking-[.16em] text-[#d2ae55]/70">SEASON VII</small>
          </button>
        </div>
      </section>

      {/* setup */}
      {layer === "setup" && (
        <Frame onClose={resetSetup}>
          <OrnateTitle kicker="Multiplayer">Game setup</OrnateTitle>
          <div className="mt-8 space-y-6">
            <Choice label="Choose your mode" options={[
              { value: "normal", title: "Normal market", sub: "Play at your own pace", icon: Users },
              { value: "ranked", title: "Competitive guild", sub: "Earn standing & MMR", icon: Shield },
            ]} selected={mode} onChange={(v) => { setMode(v as "normal"|"ranked"); setMethod(null); }} />
            {mode === "normal" && (
              <Choice label="How shall you enter?" options={[
                { value: "random", title: "Random matching", sub: "Find a table instantly", icon: Shuffle },
                { value: "create", title: "Create room", sub: "Host your own table", icon: Plus },
                { value: "join", title: "Join room", sub: "Browse open tables", icon: LogIn },
              ]} selected={method} onChange={(v) => setMethod(v as "random"|"create"|"join")} />
            )}
            {mode && (mode === "ranked" || method) && (
              <Choice label="Number of merchants" compact options={[2,3,4].map((n) => ({
                value: String(n), title: `${n} Players`,
                sub: n === 2 ? "A close duel" : n === 3 ? "A balanced market" : "A grand exchange",
                icon: n === 2 ? Swords : Users,
              }))} selected={players ? String(players) : null} onChange={(v) => setPlayers(Number(v))} />
            )}
            {selectedComplete && (
              <button
                onClick={() => {
                  if (mode === "ranked") return switchLayer("matching");
                  if (method === "join") return switchLayer("rooms");
                  if (method === "create") return switchLayer("create");
                  switchLayer("lobby");
                }}
                className="w-full border border-[#d2ae55] bg-[#d2ae55] px-5 py-4 font-['Cinzel'] text-sm tracking-[.15em] text-[#160d13] transition hover:bg-[#f0cf76]"
              >
                ENTER THE MARKET
              </button>
            )}
          </div>
        </Frame>
      )}

      {/* rooms */}
      {layer === "rooms" && (
        <Frame wide onClose={() => switchLayer("setup")}>
          <button onClick={() => switchLayer("setup")} className="mb-5 flex items-center gap-1 font-['Lato'] text-xs text-[#d2ae55]/75 hover:text-[#f5dfaa]"><ChevronLeft size={16}/> Back to setup</button>
          <OrnateTitle kicker="Open tables">Join a room</OrnateTitle>
          <div className="mt-7 grid grid-cols-[1fr_auto_auto] border-b border-[#d2ae55]/25 px-4 pb-3 font-['Lato'] text-[10px] uppercase tracking-[.16em] text-[#d2ae55]/60">
            <span>Room name</span><span className="mr-8">Players</span><span>Status</span>
          </div>
          <div className="max-h-[50vh] overflow-y-auto pr-1">
            {rooms.map(([name, count, status, locked]) => (
              <div key={name} className="grid grid-cols-[1fr_auto_auto] items-center border-b border-[#d2ae55]/10 px-4 py-4 transition hover:bg-[#d2ae55]/[.06]">
                <div className="flex items-center gap-3">
                  <span className="text-[#d2ae55]/60">{locked ? <Lock size={15}/> : <CircleDot size={15}/>}</span>
                  <span className="font-['Cinzel'] text-sm text-[#f1dfb3]">{name}</span>
                </div>
                <span className="mr-8 font-['Lato'] text-sm text-[#d7c8aa]">{count}</span>
                <button disabled={!!locked} onClick={() => !locked && switchLayer("lobby")} className={`min-w-20 border px-3 py-1.5 font-['Lato'] text-[10px] uppercase tracking-[.12em] ${locked ? "cursor-not-allowed border-white/10 text-white/30" : "border-[#d2ae55]/45 text-[#d2ae55] hover:bg-[#d2ae55]/15"}`}>
                  {locked ? status : "Join"}
                </button>
              </div>
            ))}
          </div>
          <p className="mt-4 text-center font-['Lato'] text-xs text-[#d2ae55]/55">Showing 10 of 100 rooms · scroll to discover more</p>
        </Frame>
      )}

      {/* create */}
      {layer === "create" && (
        <Frame onClose={() => switchLayer("setup")}>
          <button onClick={() => switchLayer("setup")} className="mb-5 flex items-center gap-1 font-['Lato'] text-xs text-[#d2ae55]/75 hover:text-[#f5dfaa]"><ChevronLeft size={16}/> Back to setup</button>
          <OrnateTitle kicker="Host a table">Create room</OrnateTitle>
          <div className="mt-8 space-y-5 font-['Lato']">
            <Field label="Room name"><input value={roomName} onChange={(e) => setRoomName(e.target.value)} className="input" /></Field>
            <Field label="Merchants at table">
              <div className="flex items-center gap-3 border border-[#d2ae55]/20 px-4 py-3">
                <Users size={16} className="text-[#d2ae55]/60" />
                <span className="font-['Cinzel'] text-sm text-[#f4dfaa]">{players} Players</span>
                <span className="ml-auto font-['Lato'] text-[10px] uppercase tracking-[.12em] text-[#d2ae55]/45">Selected in setup</span>
              </div>
            </Field>
            <label className="flex cursor-pointer items-center justify-between border-b border-[#d2ae55]/15 pb-4">
              <span className="text-sm text-[#e4d3b1]">Protect this room with a password</span>
              <button onClick={() => setPassword(!password)} className={`relative h-6 w-11 rounded-full border ${password ? "border-[#d2ae55] bg-[#d2ae55]/35" : "border-[#d2ae55]/30"}`}>
                <span className={`absolute top-1 h-4 w-4 rounded-full bg-[#f4dfaa] transition-all ${password ? "left-6" : "left-1"}`} />
              </button>
            </label>
            {password && <Field label="Password"><input type="password" placeholder="Enter a private password" className="input" /></Field>}
            <button onClick={() => switchLayer("lobby")} className="w-full border border-[#d2ae55] bg-[#d2ae55] py-4 font-['Cinzel'] text-sm tracking-[.14em] text-[#160d13] hover:bg-[#f0cf76]">CREATE YOUR TABLE</button>
          </div>
        </Frame>
      )}

      {/* lobby */}
      {layer === "lobby" && (
        <Frame onClose={resetSetup}>
          <OrnateTitle kicker="Private table">{roomName}</OrnateTitle>
          <p className="mt-4 text-center font-['Lato'] text-sm text-[#d2ae55]/65">{players} merchant table · Normal Market</p>
          <div className="mt-8 space-y-3">
            <PlayerSlot name="스플랜더왕" role="Host" state={ready ? "Ready" : "Preparing"} tone="bg-[#762034]" />
            <PlayerSlot name="Awaiting a merchant…" role="Open seat" state="Waiting" empty />
            <PlayerSlot name="Awaiting a merchant…" role="Open seat" state="Waiting" empty />
            {players === 4 && <PlayerSlot name="Awaiting a merchant…" role="Open seat" state="Waiting" empty />}
          </div>
          <div className="mt-7 grid grid-cols-2 gap-3">
            <button onClick={() => setReady(!ready)} className={`border py-3 font-['Cinzel'] text-xs tracking-[.12em] ${ready ? "border-[#4ca879] bg-[#4ca879]/15 text-[#7bd9a5]" : "border-[#d2ae55]/55 text-[#d2ae55] hover:bg-[#d2ae55]/10"}`}>
              {ready ? <span className="flex justify-center gap-2"><Check size={15}/> READY</span> : "MARK READY"}
            </button>
            <button className="border border-[#d2ae55] bg-[#d2ae55] py-3 font-['Cinzel'] text-xs tracking-[.12em] text-[#160d13] hover:bg-[#f0cf76]">START GAME</button>
          </div>
          <p className="mt-4 text-center font-['Lato'] text-xs text-[#d2ae55]/55">All merchants must be ready to begin.</p>
        </Frame>
      )}

      {/* leaderboard */}
      {layer === "leaderboard" && (
        <Frame wide onClose={() => setLayer(null)}>
          <div className="grid gap-8 md:grid-cols-[170px_1fr]">
            <aside className="border-b border-[#d2ae55]/20 pb-5 md:border-b-0 md:border-r md:pb-0 md:pr-5">
              <p className="mb-4 font-['Cinzel'] text-xs uppercase tracking-[.16em] text-[#d2ae55]/60">Ranked leagues</p>
              <div className="flex gap-2 md:flex-col">
                {[2,3,4].map((n) => (
                  <button key={n} onClick={() => setRankPlayers(n)} className={`flex items-center gap-3 border px-3 py-3 text-left transition ${rankPlayers === n ? "border-[#d2ae55] bg-[#d2ae55]/12 text-[#f4dfaa]" : "border-transparent text-[#d2ae55]/60 hover:bg-[#d2ae55]/5"}`}>
                    <Crown size={15}/><span className="font-['Cinzel'] text-xs">{n} PLAYER</span>
                  </button>
                ))}
              </div>
            </aside>
            <div>
              <OrnateTitle kicker={`Season VII · ${rankPlayers} player ranked`}>Guild standings</OrnateTitle>
              <div className="mt-7 grid grid-cols-2 gap-px bg-[#d2ae55]/20 sm:grid-cols-4">
                <Stat label="Your tier"         value={rankPlayers === 2 ? "GOLD II"   : rankPlayers === 3 ? "EMERALD I" : "GOLD III"} />
                <Stat label="Your rank"         value={rankPlayers === 2 ? "#210"      : rankPlayers === 3 ? "#357"      : "#512"} />
                <Stat label="Games this season" value={rankPlayers === 2 ? "9"         : rankPlayers === 3 ? "38"        : "15"} />
                <Stat label="Average place"     value={rankPlayers === 2 ? "1.7"       : rankPlayers === 3 ? "2.1"       : "2.6"} />
              </div>
              <div className="relative mt-7">
                <Search className="absolute left-3 top-3 text-[#d2ae55]/55" size={16}/>
                <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search a merchant" className="input pl-10" />
              </div>
              <div className="mt-4 max-h-[38vh] overflow-y-auto">
                <div className="grid grid-cols-[56px_1fr_90px_80px] border-b border-[#d2ae55]/25 px-3 py-2 font-['Lato'] text-[10px] uppercase tracking-[.13em] text-[#d2ae55]/60">
                  <span>Rank</span><span>Merchant</span><span>MMR</span><span>Avg.</span>
                </div>
                {Array.from({ length: 100 }, (_, i) => ({
                  rank: i + 1, name: rankingNames[i % rankingNames.length], mmr: 2482 - i * 7, avg: (1.1 + (i % 13) / 10).toFixed(1),
                })).filter((r) => r.name.toLowerCase().includes(query.toLowerCase())).map((r) => (
                  <div key={r.rank} className="grid grid-cols-[56px_1fr_90px_80px] items-center border-b border-[#d2ae55]/10 px-3 py-3 font-['Lato'] text-sm hover:bg-[#d2ae55]/[.04]">
                    <span className={r.rank < 4 ? "font-['Cinzel'] text-[#e8c45e]" : "text-[#d7c8aa]/65"}>#{r.rank}</span>
                    <span className="text-[#f0dfbb]">{r.name}</span>
                    <span className="text-[#d2ae55]">{r.mmr}</span>
                    <span className="text-[#d7c8aa]/75">{r.avg}</span>
                  </div>
                ))}
              </div>
              <p className="mt-3 text-center font-['Lato'] text-xs text-[#d2ae55]/55">100 merchants loaded · more records await below</p>
            </div>
          </div>
        </Frame>
      )}

      {/* profile */}
      {layer === "profile" && (
        <Frame onClose={() => setLayer(null)}>
          <OrnateTitle kicker="Merchant dossier">스플랜더왕</OrnateTitle>
          <div className="mt-7 flex items-center gap-5 border-b border-[#d2ae55]/20 pb-6">
            {avatar("스", "bg-[#762034]")}
            <div>
              <p className="font-['Cinzel'] text-lg text-[#f3e2bb]">스플랜더왕</p>
              <p className="mt-1 font-['Lato'] text-xs text-[#d2ae55]/65">Guild member since 10 Jul 2026</p>
            </div>
            <button className="ml-auto border border-[#d2ae55]/40 px-3 py-2 font-['Lato'] text-xs text-[#d2ae55] hover:bg-[#d2ae55]/10">Edit profile</button>
          </div>
          <div className="mt-6 grid grid-cols-4 gap-px bg-[#d2ae55]/20">
            <Stat label="Games" value="42"/><Stat label="Wins" value="27"/><Stat label="Avg score" value="15.4"/><Stat label="Avg turns" value="23.1"/>
          </div>
          <h3 className="mt-7 font-['Cinzel'] text-sm tracking-[.12em] text-[#e9d4a4]">RANKED RECORD</h3>
          <div className="mt-3 divide-y divide-[#d2ae55]/15 border-y border-[#d2ae55]/15">
            {[["2 Players","#210","1710 MMR","9 games · 1.7 avg."],["3 Players","#357","1820 MMR","38 games · 2.1 avg."],["4 Players","#512","1655 MMR","15 games · 2.6 avg."]].map((r) => (
              <div key={r[0]} className="grid grid-cols-[1fr_auto] gap-2 py-3 font-['Lato'] text-sm">
                <span className="text-[#f0dfbb]">{r[0]} <small className="ml-2 text-[#d2ae55]/60">{r[3]}</small></span>
                <span className="text-right text-[#d2ae55]">{r[1]} · {r[2]}</span>
              </div>
            ))}
          </div>
          <h3 className="mt-7 font-['Cinzel'] text-sm tracking-[.12em] text-[#e9d4a4]">RECENT GAMES</h3>
          <div className="mt-3 space-y-2">
            {[["3 Players","Unranked","2nd place"],["2 Players","Ranked","1st place"],["4 Players","Unranked","3rd place"]].map((g) => (
              <div key={g.join()} className="flex justify-between border border-[#d2ae55]/15 px-3 py-3 font-['Lato'] text-xs">
                <span>{g[0]} · <span className="text-[#d2ae55]/60">{g[1]}</span></span>
                <strong className="text-[#d2ae55]">{g[2]}</strong>
              </div>
            ))}
          </div>
        </Frame>
      )}

      {/* ranked matchmaking */}
      {layer === "matching" && (
        <MatchmakingScreen players={players!} onCancel={resetSetup} />
      )}

      {/* friends (custom overlay) */}
      {layer === "friends" && <FriendsOverlay onClose={() => setLayer(null)} />}
    </main>
  );
}

// ── matchmaking screen ────────────────────────────────────────────────────────

function MatchmakingScreen({ players, onCancel }: { players: number; onCancel: () => void }) {
  const [elapsed, setElapsed] = useState(0);
  const [dots, setDots] = useState(0);
  const [queueSize] = useState(() => 847 + Math.floor(Math.random() * 300));

  useEffect(() => {
    const t = setInterval(() => setElapsed((s) => s + 1), 1000);
    return () => clearInterval(t);
  }, []);

  useEffect(() => {
    const t = setInterval(() => setDots((d) => (d + 1) % 4), 500);
    return () => clearInterval(t);
  }, []);

  const mm = String(Math.floor(elapsed / 60)).padStart(2, "0");
  const ss = String(elapsed % 60).padStart(2, "0");
  const dotStr = ".".repeat(dots).padEnd(3, " ");

  const tierLabel = players === 2 ? "GOLD II" : players === 3 ? "EMERALD I" : "GOLD III";
  const mmr       = players === 2 ? 1710      : players === 3 ? 1820        : 1655;
  const mmrRange  = Math.min(50 + elapsed * 2, 300);

  const GEM_COLS = ["#bd3045","#2f9c74","#357fc7","#8d58a1","#d2ae55"];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-[#030205]/85 backdrop-blur-md p-4">
      <div className="relative w-full max-w-md overflow-hidden border border-[#d2ae55]/35 bg-[#100b13]/97 shadow-[0_0_100px_rgba(0,0,0,.9)]">
        <div className="pointer-events-none absolute inset-2 border border-[#d2ae55]/10" />

        {/* animated corner accents */}
        <div className="pointer-events-none absolute left-4 top-4 h-6 w-6 border-l-2 border-t-2 border-[#d2ae55]/50" />
        <div className="pointer-events-none absolute right-4 top-4 h-6 w-6 border-r-2 border-t-2 border-[#d2ae55]/50" />
        <div className="pointer-events-none absolute bottom-4 left-4 h-6 w-6 border-b-2 border-l-2 border-[#d2ae55]/50" />
        <div className="pointer-events-none absolute bottom-4 right-4 h-6 w-6 border-b-2 border-r-2 border-[#d2ae55]/50" />

        <div className="flex flex-col items-center px-10 py-12">
          {/* spinning gem ring */}
          <div className="relative mb-8 h-28 w-28">
            <style>{`
              @keyframes spin-slow { to { transform: rotate(360deg); } }
              @keyframes spin-rev  { to { transform: rotate(-360deg); } }
              @keyframes pulse-ring { 0%,100% { opacity:.15; transform:scale(.92); } 50% { opacity:.35; transform:scale(1.06); } }
            `}</style>
            {/* outer rotating ring */}
            <div className="absolute inset-0 animate-[spin-slow_4s_linear_infinite]"
              style={{ borderRadius: "50%", border: "2px dashed rgba(210,174,85,0.35)" }} />
            {/* inner pulsing ring */}
            <div className="absolute inset-4 animate-[pulse-ring_2s_ease-in-out_infinite]"
              style={{ borderRadius: "50%", border: "1px solid rgba(210,174,85,0.5)", boxShadow: "0 0 20px rgba(210,174,85,0.2)" }} />
            {/* gem dots on orbit */}
            {GEM_COLS.map((col, i) => {
              const angle = (i / GEM_COLS.length) * 360;
              return (
                <div key={col} className="absolute inset-0 animate-[spin-slow_4s_linear_infinite]"
                  style={{ transformOrigin: "center" }}>
                  <div className="absolute left-1/2 top-0 -translate-x-1/2 -translate-y-1"
                    style={{ transform: `rotate(${angle}deg) translateY(-50%) rotate(-${angle}deg)` }}>
                    <div className="h-2.5 w-2.5 rotate-45 rounded-[2px]"
                      style={{ background: col, boxShadow: `0 0 8px ${col}`, marginLeft: "-5px", marginTop: "2px" }} />
                  </div>
                </div>
              );
            })}
            {/* center shield icon */}
            <div className="absolute inset-0 flex items-center justify-center">
              <Shield size={28} style={{ color: "#d2ae55" }} strokeWidth={1.5} />
            </div>
          </div>

          {/* title */}
          <p className="font-['Lato'] text-[10px] uppercase tracking-[.35em] text-[#d2ae55]/55">Ranked · {players} Players</p>
          <h2 className="mt-2 font-['Cinzel'] text-xl font-semibold tracking-[.08em] text-[#f4dfaa]">
            Searching{dotStr}
          </h2>

          {/* stats row */}
          <div className="mt-7 grid w-full grid-cols-3 gap-px bg-[#d2ae55]/15">
            <div className="bg-[#130d19] py-3 text-center">
              <p className="font-['Cinzel'] text-sm text-[#f1dfb3]">{mm}:{ss}</p>
              <p className="mt-1 font-['Lato'] text-[9px] uppercase tracking-[.1em] text-[#d2ae55]/55">Elapsed</p>
            </div>
            <div className="bg-[#130d19] py-3 text-center">
              <p className="font-['Cinzel'] text-sm text-[#f1dfb3]">{mmr} <span className="text-[#d2ae55]/50 text-[11px]">±{mmrRange}</span></p>
              <p className="mt-1 font-['Lato'] text-[9px] uppercase tracking-[.1em] text-[#d2ae55]/55">MMR range</p>
            </div>
            <div className="bg-[#130d19] py-3 text-center">
              <p className="font-['Cinzel'] text-sm text-[#f1dfb3]">{queueSize}</p>
              <p className="mt-1 font-['Lato'] text-[9px] uppercase tracking-[.1em] text-[#d2ae55]/55">In queue</p>
            </div>
          </div>

          {/* tier badge */}
          <div className="mt-6 flex items-center gap-2.5 border border-[#d2ae55]/25 bg-[#d2ae55]/[.06] px-5 py-2.5">
            <Crown size={13} className="text-[#d2ae55]" />
            <span className="font-['Cinzel'] text-xs tracking-[.15em] text-[#d2ae55]">{tierLabel}</span>
            <span className="font-['Lato'] text-[10px] text-[#d2ae55]/45">· Current tier</span>
          </div>

          {/* progress bar */}
          <div className="relative mt-6 h-px w-full overflow-hidden bg-[#d2ae55]/10">
            <div
              className="absolute inset-y-0 left-0 bg-[#d2ae55]/60"
              style={{
                width: `${Math.min((elapsed / 60) * 100, 90)}%`,
                transition: "width 1s linear",
                boxShadow: "4px 0 12px rgba(210,174,85,0.6)",
              }}
            />
          </div>
          <p className="mt-2 font-['Lato'] text-[10px] text-[#d2ae55]/35 tracking-[.08em]">
            MMR range expands every 30 seconds
          </p>

          {/* cancel */}
          <button
            onClick={onCancel}
            className="mt-8 border border-[#d2ae55]/25 px-8 py-2.5 font-['Cinzel'] text-xs tracking-[.15em] text-[#d2ae55]/60 transition hover:border-[#d2ae55]/55 hover:text-[#d2ae55]"
          >
            CANCEL SEARCH
          </button>
        </div>
      </div>
    </div>
  );
}

// ── reusable sub-components ───────────────────────────────────────────────────

function Choice({ label, options, selected, onChange, compact = false }: {
  label: string;
  options: { value: string; title: string; sub: string; icon: typeof Users }[];
  selected: string | null;
  onChange: (value: string) => void;
  compact?: boolean;
}) {
  return (
    <div>
      <p className="mb-3 font-['Cinzel'] text-xs uppercase tracking-[.16em] text-[#d2ae55]/70">{label}</p>
      <div className={`grid gap-2 ${compact ? "grid-cols-3" : options.length === 3 ? "sm:grid-cols-3" : "sm:grid-cols-2"}`}>
        {options.map(({ value, title, sub, icon: Icon }) => (
          <button key={value} onClick={() => onChange(value)} className={`border p-3 text-left transition ${selected === value ? "border-[#d2ae55] bg-[#d2ae55]/12" : "border-[#d2ae55]/20 hover:border-[#d2ae55]/55 hover:bg-[#d2ae55]/[.05]"}`}>
            <Icon size={18} className={selected === value ? "text-[#d2ae55]" : "text-[#d2ae55]/55"} />
            <p className="mt-2 font-['Cinzel'] text-xs text-[#f1dfb3]">{title}</p>
            <p className="mt-1 font-['Lato'] text-[11px] text-[#d2ae55]/55">{sub}</p>
          </button>
        ))}
      </div>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="block">
      <span className="mb-2 block font-['Cinzel'] text-xs uppercase tracking-[.14em] text-[#d2ae55]/70">{label}</span>
      {children}
    </label>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="bg-[#130d19] p-3 text-center">
      <p className="font-['Cinzel'] text-sm text-[#f1dfb3]">{value}</p>
      <p className="mt-1 font-['Lato'] text-[9px] uppercase tracking-[.12em] text-[#d2ae55]/60">{label}</p>
    </div>
  );
}

function PlayerSlot({ name, role, state, empty = false, tone = "bg-[#34213f]" }: { name: string; role: string; state: string; empty?: boolean; tone?: string }) {
  return (
    <div className={`flex items-center gap-3 border px-4 py-3 ${empty ? "border-dashed border-[#d2ae55]/20" : "border-[#d2ae55]/25 bg-[#d2ae55]/[.04]"}`}>
      {empty
        ? <div className="grid h-10 w-10 place-items-center rounded-full border border-dashed border-[#d2ae55]/30 text-[#d2ae55]/40"><Users size={16}/></div>
        : avatar(name, tone)
      }
      <div className="flex-1">
        <p className={`font-['Lato'] text-sm ${empty ? "text-[#d2ae55]/50" : "text-[#f0dfbb]"}`}>{name}</p>
        <p className="font-['Lato'] text-[10px] uppercase tracking-[.12em] text-[#d2ae55]/55">{role}</p>
      </div>
      <span className={`font-['Cinzel'] text-[10px] tracking-[.1em] ${state === "Ready" ? "text-[#76d09c]" : "text-[#d2ae55]/55"}`}>{state}</span>
    </div>
  );
}

export default App;
