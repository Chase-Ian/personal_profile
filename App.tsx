
import React, { useState, useEffect, useRef } from 'react';
import { Screen, Profile, Project, Friend } from './types';
import { supabaseService } from './services/mockSupabase';
import { 
  User, 
  Rocket, 
  GraduationCap, 
  Image as ImageIcon, 
  Share2, 
  Lock, 
  Unlock, 
  Edit3, 
  LogOut, 
  Plus, 
  Trash2, 
  ExternalLink,
  ChevronLeft
} from 'lucide-react';

const App: React.FC = () => {
  // State
  const [currentScreen, setCurrentScreen] = useState<Screen>(Screen.MAIN);
  const [isAdmin, setIsAdmin] = useState<boolean>(false);
  const [profile, setProfile] = useState<Profile>({
    name: "Chase Ian Famisaran",
    bio: "Full-stack explorer charting the digital cosmos with precision and passion.",
    email: "chase.ian@starfleet.dev",
    skills: ["React", "Flutter", "TypeScript", "Quantum Computing", "UI/UX Design"],
    hobbies: ["Astro-Photography", "Retro Gaming", "Synthwave Production"],
    profilePic: "https://picsum.photos/seed/astronaut/400/400"
  });
  const [projects, setProjects] = useState<Project[]>([]);
  const [friends, setFriends] = useState<Friend[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Section Refs for Smooth Scroll
  const homeRef = useRef<HTMLDivElement>(null);
  const projectsRef = useRef<HTMLDivElement>(null);
  const educationRef = useRef<HTMLDivElement>(null);
  const galleryRef = useRef<HTMLDivElement>(null);
  const socialRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const fetchData = async () => {
      const p = await supabaseService.getProjects();
      const f = await supabaseService.getFriends();
      setProjects(p);
      setFriends(f);
      setIsLoading(false);
    };
    fetchData();
  }, []);

  const scrollTo = (ref: React.RefObject<HTMLDivElement>) => {
    if (currentScreen !== Screen.MAIN) {
      setCurrentScreen(Screen.MAIN);
      setTimeout(() => ref.current?.scrollIntoView({ behavior: 'smooth' }), 100);
    } else {
      ref.current?.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const handleLogin = (pass: string) => {
    if (pass === "admin123") {
      setIsAdmin(true);
      setCurrentScreen(Screen.MAIN);
      alert("ADMIN ACCESS GRANTED");
    } else {
      alert("INVALID CLEARANCE CODE");
    }
  };

  // -------------------------------------------------------------------------
  // Sub-Screens
  // -------------------------------------------------------------------------

  const RenderLogin = () => {
    const [pass, setPass] = useState('');
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#0B0D17] px-4">
        <div className="max-w-md w-full bg-[#1A1D29] p-8 rounded-lg border border-[#FF007F]/30 shadow-2xl">
          <div className="flex justify-center mb-6">
            <div className="p-4 rounded-full bg-[#FF007F]/10 border border-[#FF007F]">
              <Lock className="w-10 h-10 text-[#FF007F]" />
            </div>
          </div>
          <h2 className="text-2xl font-orbitron text-center mb-8 pink-glow">RESTRICTED_ACCESS.SYS</h2>
          <form onSubmit={(e) => { e.preventDefault(); handleLogin(pass); }}>
            <div className="mb-6">
              <label className="block text-xs uppercase tracking-widest text-gray-400 mb-2">Security Key</label>
              <input 
                type="password" 
                value={pass}
                onChange={(e) => setPass(e.target.value)}
                className="w-full bg-[#0B0D17] border border-gray-700 p-3 rounded focus:border-[#00F2FF] outline-none transition-all text-white"
                placeholder="ENTER KEYCODE"
                required
              />
            </div>
            <button className="w-full py-3 bg-[#FF007F] text-black font-bold uppercase tracking-widest rounded hover:bg-[#FF007F]/80 transition-all flex items-center justify-center gap-2">
              <Unlock className="w-4 h-4" /> AUTHORIZE
            </button>
            <button 
              type="button"
              onClick={() => setCurrentScreen(Screen.MAIN)}
              className="w-full mt-4 text-xs text-gray-500 hover:text-white uppercase tracking-tighter"
            >
              Cancel Mission
            </button>
          </form>
        </div>
      </div>
    );
  };

  const RenderEditProfile = () => {
    const [formData, setFormData] = useState(profile);
    const save = () => {
      if (confirm("Sync to Mainframe? All changes will be persisted.")) {
        setProfile(formData);
        setCurrentScreen(Screen.MAIN);
      }
    };
    return (
      <div className="min-h-screen pt-24 px-6 bg-[#0B0D17]">
        <div className="max-w-2xl mx-auto bg-[#1A1D29] p-8 rounded-xl neon-border">
          <button onClick={() => setCurrentScreen(Screen.MAIN)} className="flex items-center text-[#00F2FF] mb-6 hover:underline">
            <ChevronLeft className="w-4 h-4" /> BACK
          </button>
          <h2 className="text-3xl font-orbitron text-[#00F2FF] mb-8 neon-glow">EDIT_PROFILE.BAT</h2>
          <div className="space-y-6">
            <div>
              <label className="block text-xs uppercase text-gray-400 mb-1">Command Name</label>
              <input 
                className="w-full bg-[#0B0D17] border border-gray-700 p-3 rounded focus:border-[#00F2FF] outline-none text-white"
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
              />
            </div>
            <div>
              <label className="block text-xs uppercase text-gray-400 mb-1">Mission Log (Bio)</label>
              <textarea 
                rows={4}
                className="w-full bg-[#0B0D17] border border-gray-700 p-3 rounded focus:border-[#00F2FF] outline-none text-white"
                value={formData.bio}
                onChange={(e) => setFormData({...formData, bio: e.target.value})}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs uppercase text-gray-400 mb-1">Comm Link (Email)</label>
                <input 
                  className="w-full bg-[#0B0D17] border border-gray-700 p-3 rounded focus:border-[#00F2FF] outline-none text-white"
                  value={formData.email}
                  onChange={(e) => setFormData({...formData, email: e.target.value})}
                />
              </div>
              <div>
                <label className="block text-xs uppercase text-gray-400 mb-1">Identity Vector (Pic URL)</label>
                <input 
                  className="w-full bg-[#0B0D17] border border-gray-700 p-3 rounded focus:border-[#00F2FF] outline-none text-white"
                  value={formData.profilePic}
                  onChange={(e) => setFormData({...formData, profilePic: e.target.value})}
                />
              </div>
            </div>
            <button 
              onClick={save}
              className="w-full py-4 bg-[#00F2FF] text-[#0B0D17] font-bold rounded hover:bg-[#00F2FF]/80 transition-all uppercase tracking-widest shadow-lg shadow-[#00F2FF]/20"
            >
              SAVE CHANGES
            </button>
          </div>
        </div>
      </div>
    );
  };

  const RenderProjectsDedicated = () => {
    return (
      <div className="min-h-screen pt-24 px-6 bg-[#0B0D17]">
        <div className="max-w-6xl mx-auto">
          <button onClick={() => setCurrentScreen(Screen.MAIN)} className="flex items-center text-[#00F2FF] mb-8 hover:underline">
            <ChevronLeft className="w-4 h-4" /> BACK TO SURFACE
          </button>
          <h1 className="text-5xl font-orbitron neon-glow text-[#00F2FF] mb-12">ALL_MISSIONS.LOG</h1>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {projects.map(p => (
              <div key={p.id} className="bg-[#1A1D29] rounded-xl overflow-hidden border border-white/5 hover:border-[#00F2FF]/40 transition-all group">
                <div className="h-48 overflow-hidden">
                  <img src={p.imageUrl} alt={p.title} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                </div>
                <div className="p-6">
                  <span className="text-[#FF007F] text-[10px] font-bold tracking-[0.2em] uppercase mb-2 block">{p.category}</span>
                  <h3 className="text-xl font-orbitron mb-3 text-white">{p.title}</h3>
                  <p className="text-gray-400 text-sm leading-relaxed">{p.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  };

  const RenderFriendsList = () => {
    const [newFriend, setNewFriend] = useState({ name: '', socialUrl: '', platform: 'X' });
    const add = async () => {
      if (!newFriend.name || !newFriend.socialUrl) return;
      await supabaseService.addFriend({...newFriend, profilePic: `https://picsum.photos/seed/${newFriend.name}/100/100`});
      const updated = await supabaseService.getFriends();
      setFriends(updated);
      setNewFriend({ name: '', socialUrl: '', platform: 'X' });
    };
    const remove = async (id: string) => {
      if (confirm("Eject comrade from communications?")) {
        await supabaseService.deleteFriend(id);
        const updated = await supabaseService.getFriends();
        setFriends(updated);
      }
    };

    return (
      <div className="min-h-screen pt-24 px-6 bg-[#0B0D17]">
        <div className="max-w-4xl mx-auto">
          <button onClick={() => setCurrentScreen(Screen.MAIN)} className="flex items-center text-[#00F2FF] mb-8 hover:underline">
            <ChevronLeft className="w-4 h-4" /> BACK TO SURFACE
          </button>
          <div className="flex justify-between items-end mb-12">
            <h1 className="text-5xl font-orbitron neon-glow text-[#00F2FF]">CREW_MANIFEST.DAT</h1>
            {isAdmin && <span className="text-[#FF007F] text-xs font-bold px-3 py-1 border border-[#FF007F] rounded-full">ADMIN_ACTIVE</span>}
          </div>

          {isAdmin && (
            <div className="bg-[#1A1D29] p-6 rounded-xl border border-[#00F2FF]/20 mb-12">
              <h3 className="font-orbitron text-sm text-[#00F2FF] mb-4 uppercase">Recruit New Crew Member</h3>
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <input 
                  placeholder="NAME"
                  className="bg-[#0B0D17] border border-gray-700 p-3 rounded text-sm text-white focus:border-[#00F2FF] outline-none"
                  value={newFriend.name}
                  onChange={e => setNewFriend({...newFriend, name: e.target.value})}
                />
                <input 
                  placeholder="SOCIAL LINK"
                  className="bg-[#0B0D17] border border-gray-700 p-3 rounded text-sm text-white focus:border-[#00F2FF] outline-none"
                  value={newFriend.socialUrl}
                  onChange={e => setNewFriend({...newFriend, socialUrl: e.target.value})}
                />
                <select 
                  className="bg-[#0B0D17] border border-gray-700 p-3 rounded text-sm text-white focus:border-[#00F2FF] outline-none"
                  value={newFriend.platform}
                  onChange={e => setNewFriend({...newFriend, platform: e.target.value})}
                >
                  <option value="X">X / Twitter</option>
                  <option value="GitHub">GitHub</option>
                  <option value="LinkedIn">LinkedIn</option>
                </select>
                <button 
                  onClick={add}
                  className="bg-[#00F2FF] text-black font-bold text-sm rounded flex items-center justify-center gap-2 hover:bg-cyan-300 transition-all"
                >
                  <Plus className="w-4 h-4" /> ADD FRIEND
                </button>
              </div>
            </div>
          )}

          <div className="space-y-4">
            {friends.map(f => (
              <div key={f.id} className="bg-[#1A1D29] p-4 rounded-xl border border-white/5 flex items-center justify-between group hover:border-[#00F2FF]/20 transition-all">
                <div className="flex items-center gap-4">
                  <img src={f.profilePic} className="w-12 h-12 rounded-full border-2 border-[#00F2FF]/20" alt="" />
                  <div>
                    <h4 className="font-orbitron text-lg text-white">{f.name}</h4>
                    <a href={f.socialUrl} target="_blank" className="text-xs text-[#00F2FF] hover:underline flex items-center gap-1">
                      {f.platform} <ExternalLink className="w-3 h-3" />
                    </a>
                  </div>
                </div>
                {isAdmin && (
                  <button onClick={() => remove(f.id)} className="p-2 text-gray-500 hover:text-[#FF007F] transition-colors">
                    <Trash2 className="w-5 h-5" />
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  };

  // -------------------------------------------------------------------------
  // Main Layout & Landing
  // -------------------------------------------------------------------------

  if (currentScreen === Screen.LOGIN) return <RenderLogin />;
  if (currentScreen === Screen.EDIT_PROFILE) return <RenderEditProfile />;
  if (currentScreen === Screen.PROJECTS_DEDICATED) return <RenderProjectsDedicated />;
  if (currentScreen === Screen.FRIENDS_LIST) return <RenderFriendsList />;

  return (
    <div className="relative">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-[#0B0D17]/80 backdrop-blur-md border-bottom border-white/5 py-4 px-8 flex justify-between items-center">
        <div className="flex items-center gap-2">
          <Rocket className="w-6 h-6 text-[#00F2FF]" />
          <span className="font-orbitron font-bold tracking-widest text-lg">PORTFOLIO.OS</span>
        </div>
        <div className="hidden md:flex items-center gap-8 text-[10px] font-bold tracking-[0.3em] text-white/70">
          <button onClick={() => scrollTo(homeRef)} className="hover:text-[#00F2FF] transition-colors">HOME</button>
          <button onClick={() => scrollTo(projectsRef)} className="hover:text-[#00F2FF] transition-colors">PROJECTS</button>
          <button onClick={() => scrollTo(educationRef)} className="hover:text-[#00F2FF] transition-colors">EDUCATION</button>
          <button onClick={() => scrollTo(galleryRef)} className="hover:text-[#00F2FF] transition-colors">GALLERY</button>
          <button onClick={() => scrollTo(socialRef)} className="hover:text-[#00F2FF] transition-colors">SOCIAL</button>
        </div>
        <div className="flex items-center gap-4">
          {!isAdmin ? (
            <button 
              onClick={() => setCurrentScreen(Screen.LOGIN)}
              className="p-2 border border-white/10 rounded-full hover:bg-white/5 transition-all"
            >
              <Lock className="w-4 h-4 text-white/40" />
            </button>
          ) : (
            <div className="flex items-center gap-2">
               <button 
                onClick={() => setCurrentScreen(Screen.EDIT_PROFILE)}
                className="p-2 border border-[#00F2FF]/40 bg-[#00F2FF]/10 rounded-full hover:bg-[#00F2FF]/20 transition-all"
              >
                <Edit3 className="w-4 h-4 text-[#00F2FF]" />
              </button>
               <button 
                onClick={() => { setIsAdmin(false); alert("ADMIN_SESSION_TERMINATED"); }}
                className="p-2 border border-[#FF007F]/40 bg-[#FF007F]/10 rounded-full hover:bg-[#FF007F]/20 transition-all"
              >
                <LogOut className="w-4 h-4 text-[#FF007F]" />
              </button>
            </div>
          )}
        </div>
      </nav>

      {/* Hero / Home */}
      <section ref={homeRef} className="min-h-screen flex flex-col justify-center items-center relative px-6 text-center">
        <div className="absolute inset-0 overflow-hidden pointer-events-none opacity-20">
          <div className="star-field"></div>
        </div>
        <div className="mb-8 relative">
           <div className="w-48 h-48 rounded-full border-4 border-[#00F2FF] p-1 neon-border animate-pulse shadow-lg shadow-[#00F2FF]/20">
             <img src={profile.profilePic} className="w-full h-full rounded-full object-cover grayscale hover:grayscale-0 transition-all duration-700" alt="Avatar" />
           </div>
        </div>
        <h1 className="text-6xl md:text-8xl font-orbitron font-black tracking-tighter mb-4 text-[#00F2FF] neon-glow">
          {profile.name.toUpperCase()}
        </h1>
        <p className="max-w-xl text-lg md:text-xl text-gray-400 font-light leading-relaxed mb-8">
          {profile.bio}
        </p>
        <div className="flex flex-wrap justify-center gap-4">
          {profile.skills.map(s => (
            <span key={s} className="px-4 py-2 bg-white/5 border border-white/10 rounded-full text-[10px] font-bold tracking-widest uppercase hover:bg-[#00F2FF]/10 hover:border-[#00F2FF] transition-all cursor-default">
              {s}
            </span>
          ))}
        </div>
      </section>

      {/* Projects Preview */}
      <section ref={projectsRef} className="py-32 px-6 bg-[#0B0D17] border-t border-white/5">
        <div className="max-w-6xl mx-auto">
          <div className="flex flex-col md:flex-row md:items-end justify-between mb-16 gap-6">
            <div>
              <h2 className="text-4xl font-orbitron neon-glow text-white flex items-center gap-4">
                <Rocket className="w-8 h-8 text-[#00F2FF]" /> LATEST_MISSIONS
              </h2>
              <p className="text-gray-500 mt-2">The cutting edge of my digital exploration.</p>
            </div>
            <button 
              onClick={() => setCurrentScreen(Screen.PROJECTS_DEDICATED)}
              className="px-8 py-3 bg-[#00F2FF]/10 border border-[#00F2FF]/30 text-[#00F2FF] font-orbitron text-xs hover:bg-[#00F2FF] hover:text-[#0B0D17] transition-all rounded shadow-lg shadow-[#00F2FF]/5"
            >
              VIEW_ALL_LOGS
            </button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
            {projects.slice(0, 2).map(p => (
              <div key={p.id} className="group relative bg-[#1A1D29] rounded-2xl overflow-hidden neon-border">
                <div className="aspect-video overflow-hidden">
                  <img src={p.imageUrl} alt={p.title} className="w-full h-full object-cover grayscale group-hover:grayscale-0 group-hover:scale-105 transition-all duration-1000" />
                </div>
                <div className="p-8">
                   <h3 className="text-2xl font-orbitron mb-4 group-hover:text-[#00F2FF] transition-colors">{p.title}</h3>
                   <p className="text-gray-400 leading-relaxed mb-6">{p.description}</p>
                   <button className="text-[#FF007F] font-bold text-xs tracking-widest uppercase flex items-center gap-2 group-hover:translate-x-2 transition-all">
                     View Mission Brief <ExternalLink className="w-4 h-4" />
                   </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Education */}
      <section ref={educationRef} className="py-32 px-6 bg-[#0B0D17] border-t border-white/5">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-4xl font-orbitron neon-glow text-white flex items-center gap-4 mb-16">
            <GraduationCap className="w-8 h-8 text-[#FF007F]" /> ACADEMIC_TRACKS
          </h2>
          <div className="space-y-12 border-l border-white/10 pl-8 ml-4">
            <div className="relative">
              <div className="absolute -left-[41px] top-0 w-4 h-4 bg-[#FF007F] rounded-full shadow-lg shadow-[#FF007F]/40"></div>
              <h4 className="text-xl font-orbitron text-white">Advanced Galactic Engineering</h4>
              <span className="text-[#00F2FF] text-xs font-bold tracking-widest block mb-4">UNIVERSITY OF ANDROMEDA | 2020 - 2024</span>
              <p className="text-gray-400 leading-relaxed">Specialized in neural interface design and high-density state management systems.</p>
            </div>
            <div className="relative">
              <div className="absolute -left-[41px] top-0 w-4 h-4 bg-white/20 rounded-full"></div>
              <h4 className="text-xl font-orbitron text-white">Aeronautics & Information Systems</h4>
              <span className="text-[#00F2FF] text-xs font-bold tracking-widest block mb-4">STARFLEET ACADEMY | 2016 - 2020</span>
              <p className="text-gray-400 leading-relaxed">Comprehensive study of legacy systems integration and secure protocol development.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Gallery */}
      <section ref={galleryRef} className="py-32 px-6 bg-[#0B0D17] border-t border-white/5">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-orbitron neon-glow text-white flex items-center gap-4 mb-16">
            <ImageIcon className="w-8 h-8 text-[#00F2FF]" /> VISUAL_ARCHIVE
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[1, 2, 3, 4, 5, 6, 7, 8].map(i => (
              <div key={i} className="aspect-square rounded-lg overflow-hidden border border-white/5 hover:border-[#00F2FF]/40 transition-all cursor-zoom-in group">
                <img src={`https://picsum.photos/seed/${i + 50}/600/600`} className="w-full h-full object-cover group-hover:scale-110 transition-all duration-700 opacity-60 hover:opacity-100" alt="" />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Social / Contact */}
      <section ref={socialRef} className="py-32 px-6 bg-[#0B0D17] border-t border-white/5 relative">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-12">
          <div className="text-center md:text-left">
            <h2 className="text-4xl font-orbitron neon-glow text-white flex items-center gap-4 mb-4 justify-center md:justify-start">
              <Share2 className="w-8 h-8 text-[#FF007F]" /> COMMS_CHANNEL
            </h2>
            <p className="text-gray-400 max-w-sm">Ready to embark on the next mission together. Drop a transmission.</p>
          </div>
          <div className="flex flex-wrap justify-center gap-8">
            <button 
              onClick={() => setCurrentScreen(Screen.FRIENDS_LIST)}
              className="px-10 py-5 bg-[#1A1D29] border border-[#00F2FF]/40 text-[#00F2FF] font-orbitron rounded-xl hover:bg-[#00F2FF]/10 transition-all shadow-xl flex items-center gap-4"
            >
              <User className="w-6 h-6" /> CREW_MANIFEST
            </button>
            <div className="flex items-center gap-6">
              <a href="#" className="p-4 bg-white/5 rounded-full hover:bg-[#FF007F]/20 hover:text-[#FF007F] transition-all border border-white/10"><Share2 className="w-6 h-6" /></a>
              <a href="#" className="p-4 bg-white/5 rounded-full hover:bg-[#00F2FF]/20 hover:text-[#00F2FF] transition-all border border-white/10"><ImageIcon className="w-6 h-6" /></a>
              <a href={`mailto:${profile.email}`} className="p-4 bg-white/5 rounded-full hover:bg-[#FF007F]/20 hover:text-[#FF007F] transition-all border border-white/10"><Edit3 className="w-6 h-6" /></a>
            </div>
          </div>
        </div>
        <div className="mt-24 text-center text-[10px] tracking-[0.4em] text-white/20 font-bold uppercase">
          © {new Date().getFullYear()} CHASE_IAN_FAMISARAN.SYS | ALL_SYSTEMS_OPERATIONAL
        </div>
      </section>
    </div>
  );
};

export default App;
