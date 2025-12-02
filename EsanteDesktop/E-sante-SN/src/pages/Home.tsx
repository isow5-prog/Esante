import { 
  Search, Users, ClipboardCheck, Baby, QrCode, 
  ScanLine, FilePlus, CheckCircle2, 
  AlertCircle, ArrowRight, Sparkles, Heart,
  Calendar, Stethoscope
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import Header from "@/components/Header";
import StatCard from "@/components/StatCard";
import { api, Mother } from "@/lib/api";

const Home = () => {
  const navigate = useNavigate();
  const { data: stats } = useQuery({
    queryKey: ["stats"],
    queryFn: api.getStats,
  });
  const { data: recent } = useQuery({
    queryKey: ["recent-mothers"],
    queryFn: api.getRecentMothers,
  });

  const statsValues = {
    mothers: stats?.mothers ?? 0,
    consultations: stats?.consultations ?? 0,
    children: stats?.children_followed ?? 0,
  };

  const recentPatients: Mother[] = recent ?? [];

  return (
    <div className="min-h-screen bg-background">
      <Header />
      
      <main className="max-w-7xl mx-auto p-6">
        {/* Welcome Banner */}
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary via-primary/95 to-emerald-700 p-8 mb-8 animate-slide-up">
          <div className="absolute inset-0 pattern-dots opacity-20" />
          <div className="absolute -right-20 -top-20 w-80 h-80 bg-white/10 rounded-full blur-3xl" />
          <div className="absolute -left-10 -bottom-10 w-60 h-60 bg-emerald-300/20 rounded-full blur-2xl" />
          
          <div className="relative flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div className="text-white">
              <div className="flex items-center gap-2 mb-2">
                <Stethoscope className="w-5 h-5 text-emerald-200" />
                <span className="text-emerald-100 text-sm font-medium">Espace Agent de Santé</span>
              </div>
              <h1 className="text-3xl font-bold mb-2">
                Bonjour, Sage-femme 👋
              </h1>
              <p className="text-white/80 max-w-md">
                Gérez vos patientes, validez les cartes QR et suivez les consultations prénatales.
              </p>
            </div>
            
            <div className="flex flex-col sm:flex-row gap-3">
              <Button 
                onClick={() => navigate("/consult-record")}
                size="lg"
                className="bg-white text-primary hover:bg-white/90 shadow-xl shadow-black/20 rounded-2xl h-14 px-6 font-semibold"
              >
                <ScanLine className="mr-2 w-5 h-5" />
                Consulter dossier
              </Button>
              <Button 
                onClick={() => navigate("/validate-card")}
                size="lg"
                variant="outline"
                className="bg-white/10 text-white border-white/30 hover:bg-white/20 rounded-2xl h-14 px-6 font-semibold"
              >
                <CheckCircle2 className="mr-2 w-5 h-5" />
                Valider une carte
              </Button>
            </div>
          </div>
        </div>

        {/* Search Section */}
        <div className="bg-card rounded-2xl border border-border/50 p-6 mb-8 animate-slide-up delay-100">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
              <Search className="w-5 h-5 text-primary" />
            </div>
            <div>
              <h2 className="font-semibold">Rechercher un Dossier</h2>
              <p className="text-sm text-muted-foreground">Scanner un QR code ou entrer l'identifiant</p>
            </div>
          </div>
          
          <div className="flex gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
              <Input
                placeholder="Rechercher par nom, téléphone ou code QR..."
                className="pl-12 h-12 rounded-xl bg-muted/50 border-border/50"
              />
            </div>
            <Button className="h-12 px-6 rounded-xl">
              <ScanLine className="mr-2 w-5 h-5" />
              Scanner QR
            </Button>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="animate-slide-up delay-100">
            <StatCard
              icon={Users}
              title="Mes Patientes"
              value={statsValues.mothers}
              subtitle="Mères inscrites"
              trend={5}
              color="green"
            />
          </div>
          <div className="animate-slide-up delay-200">
            <StatCard
              icon={ClipboardCheck}
              title="CPN Aujourd'hui"
              value={8}
              subtitle="Consultations prévues"
              color="blue"
            />
          </div>
          <div className="animate-slide-up delay-300">
            <StatCard
              icon={Baby}
              title="Naissances ce mois"
              value={12}
              subtitle="Accouchements réussis"
              trend={20}
              color="purple"
            />
          </div>
          <div className="animate-slide-up delay-400">
            <StatCard
              icon={Heart}
              title="Vaccinations"
              value={statsValues.consultations}
              subtitle="Effectuées ce mois"
              color="rose"
            />
          </div>
        </div>

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Recent Patients */}
          <div className="lg:col-span-2 animate-slide-up delay-200">
            <div className="bg-card rounded-2xl border border-border/50 p-6 h-full">
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                    <Users className="w-5 h-5 text-primary" />
                  </div>
                  <div>
                    <h2 className="font-bold">Patientes Récentes</h2>
                    <p className="text-sm text-muted-foreground">Dernières inscriptions</p>
                  </div>
                </div>
                <Button variant="ghost" size="sm" className="text-primary">
                  Voir tout <ArrowRight className="ml-1 w-4 h-4" />
                </Button>
              </div>

              <div className="space-y-3">
                {recentPatients.length > 0 ? (
                  recentPatients.slice(0, 5).map((patient, index) => (
                    <div 
                      key={patient.id} 
                      className="flex items-center justify-between p-4 rounded-xl bg-muted/50 hover:bg-muted transition-colors cursor-pointer group animate-slide-in-right"
                      style={{ animationDelay: `${index * 100}ms` }}
                    >
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary/20 to-emerald-500/20 flex items-center justify-center">
                          <span className="text-lg font-bold text-primary">
                            {patient.full_name.charAt(0)}
                          </span>
                        </div>
                        <div>
                          <div className="font-medium group-hover:text-primary transition-colors">
                            {patient.full_name}
                          </div>
                          <div className="flex items-center gap-2 text-sm text-muted-foreground">
                            <QrCode className="w-3 h-3" />
                            {patient.qr_code ?? `Mère-${patient.id}`}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <div className="text-right">
                          <div className={`flex items-center gap-1 text-sm font-medium ${
                            patient.qr_status === "validated" ? 'text-emerald-600' : 'text-amber-600'
                          }`}>
                            {patient.qr_status === "validated" ? (
                              <><CheckCircle2 className="w-4 h-4" /> Validé</>
                            ) : (
                              <><AlertCircle className="w-4 h-4" /> En attente</>
                            )}
                          </div>
                          <div className="text-xs text-muted-foreground">
                            {new Date(patient.created_at).toLocaleDateString("fr-FR")}
                          </div>
                        </div>
                        <ArrowRight className="w-5 h-5 text-muted-foreground opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="text-center py-12">
                    <Users className="w-16 h-16 mx-auto text-muted-foreground/30 mb-4" />
                    <p className="text-muted-foreground">Aucune patiente récente</p>
                    <Button 
                      className="mt-4"
                      onClick={() => navigate("/validate-card")}
                    >
                      <ScanLine className="mr-2 w-4 h-4" />
                      Valider une carte
                    </Button>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Today's Schedule */}
          <div className="animate-slide-up delay-300">
            <div className="bg-card rounded-2xl border border-border/50 p-6 h-full">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center">
                  <Calendar className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <h2 className="font-bold">Aujourd'hui</h2>
                  <p className="text-sm text-muted-foreground">Rendez-vous prévus</p>
                </div>
              </div>

              <div className="space-y-4">
                {[
                  { time: "09:00", name: "Fatou Diallo", type: "CPN 3", status: "done" },
                  { time: "10:30", name: "Aminata Sow", type: "Vaccination", status: "done" },
                  { time: "11:30", name: "Awa Ndiaye", type: "CPN 2", status: "current" },
                  { time: "14:00", name: "Marie Faye", type: "CPN 1", status: "pending" },
                  { time: "15:30", name: "Khady Ba", type: "Contrôle", status: "pending" },
                ].map((rdv, index) => (
                  <div 
                    key={index}
                    className={`flex items-center gap-4 p-3 rounded-xl transition-colors ${
                      rdv.status === "current" 
                        ? "bg-primary/10 border border-primary/30" 
                        : rdv.status === "done"
                        ? "opacity-60"
                        : "hover:bg-muted/50"
                    }`}
                  >
                    <div className={`w-2 h-2 rounded-full ${
                      rdv.status === "done" ? "bg-emerald-500" :
                      rdv.status === "current" ? "bg-primary animate-pulse" :
                      "bg-muted-foreground/30"
                    }`} />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-medium">{rdv.time}</span>
                        <span className="text-xs bg-muted px-2 py-0.5 rounded-full">{rdv.type}</span>
                      </div>
                      <p className="text-sm text-muted-foreground truncate">{rdv.name}</p>
                    </div>
                    {rdv.status === "done" && (
                      <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                    )}
                  </div>
                ))}
              </div>

              <Button variant="outline" className="w-full mt-4 rounded-xl">
                <Calendar className="mr-2 w-4 h-4" />
                Voir le calendrier
              </Button>
            </div>
          </div>
        </div>

      </main>
    </div>
  );
};

export default Home;
