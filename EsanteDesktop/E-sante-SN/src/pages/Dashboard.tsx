import { 
  Users, ClipboardCheck, Baby, Building2, QrCode, 
  MessageSquare, BarChart3, UserPlus, ArrowRight,
  TrendingUp, Calendar, Bell, Sparkles
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import Header from "@/components/Header";
import StatCard from "@/components/StatCard";
import { api, HealthCenter } from "@/lib/api";
import { AreaChart, Area, ResponsiveContainer, Tooltip, XAxis } from "recharts";

// Mini chart data
const miniChartData = [
  { name: "Lun", value: 12 },
  { name: "Mar", value: 19 },
  { name: "Mer", value: 15 },
  { name: "Jeu", value: 22 },
  { name: "Ven", value: 28 },
  { name: "Sam", value: 18 },
  { name: "Dim", value: 8 },
];

const Dashboard = () => {
  const navigate = useNavigate();
  const { data: stats } = useQuery({
    queryKey: ["stats"],
    queryFn: api.getStats,
  });
  const { data: centers } = useQuery({
    queryKey: ["centers"],
    queryFn: api.getCenters,
  });

  const statsValues = {
    mothers: stats?.mothers ?? 0,
    consultations: stats?.consultations ?? 0,
    children: stats?.children_followed ?? 0,
  };
  const healthCenters: HealthCenter[] = centers ?? [];

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-7xl mx-auto p-6">
        {/* Welcome Banner */}
        <div className="relative overflow-hidden rounded-3xl gradient-hero p-8 mb-8 animate-slide-up">
          <div className="absolute inset-0 pattern-dots opacity-20" />
          <div className="absolute -right-20 -top-20 w-80 h-80 bg-white/10 rounded-full blur-3xl" />
          <div className="absolute -left-10 -bottom-10 w-60 h-60 bg-emerald-300/20 rounded-full blur-2xl" />
          
          <div className="relative flex items-center justify-between">
            <div className="text-white">
              <div className="flex items-center gap-2 mb-2">
                <Sparkles className="w-5 h-5 text-emerald-200" />
                <span className="text-emerald-100 text-sm font-medium">Tableau de bord Ministère</span>
              </div>
              <h1 className="text-3xl font-bold mb-2">
                Bienvenue sur E-Santé SN 👋
              </h1>
              <p className="text-white/80 max-w-lg">
                Gérez les QR codes, suivez les statistiques et diffusez les messages 
                de prévention à travers tout le Sénégal.
              </p>
            </div>
            
            <Button 
              onClick={() => navigate("/qr-generation")}
              size="lg"
              className="bg-white text-primary hover:bg-white/90 shadow-xl shadow-black/20 rounded-2xl h-14 px-8 font-semibold"
            >
              <QrCode className="mr-2 w-5 h-5" />
              Générer QR Codes
            </Button>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="animate-slide-up delay-100">
            <StatCard
              icon={Users}
              title="Mères Inscrites"
              value={statsValues.mothers}
              subtitle="Carnets enregistrés"
              trend={12}
              color="green"
            />
          </div>
          <div className="animate-slide-up delay-200">
            <StatCard
              icon={ClipboardCheck}
              title="CPN Effectuées"
              value={statsValues.consultations}
              subtitle="Ce mois-ci"
              trend={8}
              color="blue"
            />
          </div>
          <div className="animate-slide-up delay-300">
            <StatCard
              icon={Baby}
              title="Enfants Suivis"
              value={statsValues.children}
              subtitle="De 0 à 18 ans"
              trend={15}
              color="purple"
            />
          </div>
          <div className="animate-slide-up delay-400">
            <StatCard
              icon={Building2}
              title="Centres Actifs"
              value={healthCenters.length}
              subtitle="Dans tout le pays"
              color="orange"
            />
          </div>
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* Quick Actions */}
          <div className="lg:col-span-2 animate-slide-up delay-200">
            <div className="bg-card rounded-2xl border border-border/50 p-6 h-full">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold flex items-center gap-2">
                  <Sparkles className="w-5 h-5 text-primary" />
                  Actions rapides
                </h2>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* QR Generation */}
                <button 
                  onClick={() => navigate("/qr-generation")}
                  className="group relative overflow-hidden rounded-2xl p-6 bg-gradient-to-br from-emerald-50 to-green-50 dark:from-emerald-950/30 dark:to-green-950/30 border border-emerald-200 dark:border-emerald-800 hover:border-primary transition-all duration-300 text-left"
                >
                  <div className="absolute -right-6 -top-6 w-24 h-24 bg-primary/10 rounded-full group-hover:scale-150 transition-transform duration-500" />
                  <div className="relative">
                    <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <QrCode className="w-6 h-6 text-primary" />
                    </div>
                    <h3 className="font-semibold mb-1">Générer QR Codes</h3>
                    <p className="text-sm text-muted-foreground">Créer de nouvelles cartes QR</p>
                  </div>
                  <ArrowRight className="absolute right-4 bottom-4 w-5 h-5 text-primary opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
                </button>

                {/* Messages */}
                <button 
                  onClick={() => navigate("/messages")}
                  className="group relative overflow-hidden rounded-2xl p-6 bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-950/30 dark:to-indigo-950/30 border border-blue-200 dark:border-blue-800 hover:border-blue-500 transition-all duration-300 text-left"
                >
                  <div className="absolute -right-6 -top-6 w-24 h-24 bg-blue-500/10 rounded-full group-hover:scale-150 transition-transform duration-500" />
                  <div className="relative">
                    <div className="w-12 h-12 rounded-xl bg-blue-500/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <MessageSquare className="w-6 h-6 text-blue-600" />
                    </div>
                    <h3 className="font-semibold mb-1">Messages Prévention</h3>
                    <p className="text-sm text-muted-foreground">Diffuser des conseils santé</p>
                  </div>
                  <ArrowRight className="absolute right-4 bottom-4 w-5 h-5 text-blue-600 opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
                </button>

                {/* Statistics */}
                <button 
                  onClick={() => navigate("/statistics")}
                  className="group relative overflow-hidden rounded-2xl p-6 bg-gradient-to-br from-purple-50 to-violet-50 dark:from-purple-950/30 dark:to-violet-950/30 border border-purple-200 dark:border-purple-800 hover:border-purple-500 transition-all duration-300 text-left"
                >
                  <div className="absolute -right-6 -top-6 w-24 h-24 bg-purple-500/10 rounded-full group-hover:scale-150 transition-transform duration-500" />
                  <div className="relative">
                    <div className="w-12 h-12 rounded-xl bg-purple-500/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <BarChart3 className="w-6 h-6 text-purple-600" />
                    </div>
                    <h3 className="font-semibold mb-1">Statistiques</h3>
                    <p className="text-sm text-muted-foreground">Analyser les données</p>
                  </div>
                  <ArrowRight className="absolute right-4 bottom-4 w-5 h-5 text-purple-600 opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
                </button>

                {/* Users */}
                <button 
                  onClick={() => navigate("/users")}
                  className="group relative overflow-hidden rounded-2xl p-6 bg-gradient-to-br from-orange-50 to-amber-50 dark:from-orange-950/30 dark:to-amber-950/30 border border-orange-200 dark:border-orange-800 hover:border-orange-500 transition-all duration-300 text-left"
                >
                  <div className="absolute -right-6 -top-6 w-24 h-24 bg-orange-500/10 rounded-full group-hover:scale-150 transition-transform duration-500" />
                  <div className="relative">
                    <div className="w-12 h-12 rounded-xl bg-orange-500/10 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                      <UserPlus className="w-6 h-6 text-orange-600" />
                    </div>
                    <h3 className="font-semibold mb-1">Gestion Utilisateurs</h3>
                    <p className="text-sm text-muted-foreground">Agents de santé</p>
                  </div>
                  <ArrowRight className="absolute right-4 bottom-4 w-5 h-5 text-orange-600 opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
                </button>
              </div>
            </div>
          </div>

          {/* Health Centers */}
          <div className="animate-slide-up delay-300">
            <div className="bg-card rounded-2xl border border-border/50 p-6 h-full">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-lg font-bold flex items-center gap-2">
                  <Building2 className="w-5 h-5 text-primary" />
                  Centres de Santé
                </h2>
                <span className="text-sm text-muted-foreground bg-muted px-3 py-1 rounded-full">
                  {healthCenters.length} actifs
                </span>
              </div>
              
              <div className="space-y-3 max-h-64 overflow-y-auto pr-2">
                {healthCenters.length > 0 ? (
                  healthCenters.slice(0, 5).map((center, index) => (
                    <div 
                      key={center.id} 
                      className="flex items-center justify-between p-3 rounded-xl bg-muted/50 hover:bg-muted transition-colors animate-slide-in-right"
                      style={{ animationDelay: `${index * 100}ms` }}
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                          <Building2 className="w-5 h-5 text-primary" />
                        </div>
                        <div>
                          <div className="font-medium text-sm">{center.name}</div>
                          <div className="text-xs text-muted-foreground">{center.city}</div>
                        </div>
                      </div>
                      <span className="text-xs font-mono text-muted-foreground bg-background px-2 py-1 rounded">
                        {center.code}
                      </span>
                    </div>
                  ))
                ) : (
                  <div className="text-center py-8 text-muted-foreground">
                    <Building2 className="w-12 h-12 mx-auto mb-3 opacity-30" />
                    <p className="text-sm">Aucun centre enregistré</p>
                  </div>
                )}
              </div>

              <Button 
                variant="outline"
                className="w-full mt-4 rounded-xl h-11 border-dashed"
                onClick={() => navigate("/add-center")}
              >
                <Building2 className="mr-2 w-4 h-4" />
                Ajouter un centre
              </Button>
            </div>
          </div>
        </div>

        {/* Bottom Row */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Mini Chart */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-400">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-bold flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-primary" />
                Cette semaine
              </h2>
            </div>
            <div className="text-3xl font-bold text-primary mb-2">122</div>
            <p className="text-sm text-muted-foreground mb-4">Nouvelles inscriptions</p>
            
            <div className="h-32">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={miniChartData}>
                  <defs>
                    <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#10b981" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <XAxis 
                    dataKey="name" 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={10}
                    tickLine={false}
                    axisLine={false}
                  />
                  <Tooltip 
                    contentStyle={{ 
                      background: 'hsl(var(--card))', 
                      border: '1px solid hsl(var(--border))',
                      borderRadius: '12px',
                      boxShadow: '0 10px 40px -10px rgba(0,0,0,0.2)'
                    }}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="value" 
                    stroke="#10b981" 
                    strokeWidth={2}
                    fillOpacity={1} 
                    fill="url(#colorValue)" 
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Recent Activity */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-400">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-bold flex items-center gap-2">
                <Calendar className="w-5 h-5 text-primary" />
                Activité Récente
              </h2>
              <Button variant="ghost" size="sm" className="text-primary">
                Voir tout
              </Button>
            </div>
            
            <div className="space-y-4">
              {[
                { icon: QrCode, text: "50 QR codes générés", time: "Il y a 2h", color: "text-emerald-500 bg-emerald-50" },
                { icon: Users, text: "12 nouvelles inscriptions", time: "Il y a 5h", color: "text-blue-500 bg-blue-50" },
                { icon: MessageSquare, text: "Message publié", time: "Hier", color: "text-purple-500 bg-purple-50" },
              ].map((item, index) => (
                <div key={index} className="flex items-center gap-4 p-3 rounded-xl hover:bg-muted/50 transition-colors">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${item.color}`}>
                    <item.icon className="w-5 h-5" />
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-medium">{item.text}</p>
                    <p className="text-xs text-muted-foreground">{item.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Notifications */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-500">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-bold flex items-center gap-2">
                <Bell className="w-5 h-5 text-primary" />
                Notifications
              </h2>
              <span className="bg-primary text-white text-xs font-bold px-2 py-1 rounded-full">
                3 nouvelles
              </span>
            </div>
            
            <div className="space-y-4">
              {[
                { title: "Nouvelle campagne vaccinale", desc: "Démarrage prévu le 15 décembre", urgent: true },
                { title: "Rapport mensuel", desc: "Le rapport de novembre est disponible", urgent: false },
                { title: "Mise à jour système", desc: "Maintenance prévue ce weekend", urgent: false },
              ].map((notif, index) => (
                <div key={index} className="flex items-start gap-4 p-3 rounded-xl hover:bg-muted/50 transition-colors cursor-pointer">
                  <div className={`w-2 h-2 rounded-full mt-2 ${notif.urgent ? 'bg-rose-500' : 'bg-muted-foreground/30'}`} />
                  <div className="flex-1">
                    <p className="text-sm font-medium">{notif.title}</p>
                    <p className="text-xs text-muted-foreground">{notif.desc}</p>
                  </div>
                </div>
              ))}
            </div>

            <Button className="w-full mt-4 rounded-xl">
              <MessageSquare className="mr-2 w-4 h-4" />
              Publier un message
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
