import {
  BarChart3,
  TrendingUp,
  Users,
  Baby,
  ClipboardCheck,
  Building2,
  Calendar,
  ArrowUpRight,
  ArrowDownRight,
  Download,
  Sparkles,
  Activity,
  Heart,
  Syringe,
} from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import Header from "@/components/Header";
import StatCard from "@/components/StatCard";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  Legend,
} from "recharts";

// Données fictives pour le prototype
const monthlyData = [
  { month: "Jan", mothers: 45, consultations: 120, children: 15, vaccinations: 80 },
  { month: "Fév", mothers: 52, consultations: 145, children: 18, vaccinations: 95 },
  { month: "Mar", mothers: 48, consultations: 138, children: 22, vaccinations: 88 },
  { month: "Avr", mothers: 61, consultations: 165, children: 25, vaccinations: 110 },
  { month: "Mai", mothers: 55, consultations: 152, children: 20, vaccinations: 102 },
  { month: "Jun", mothers: 72, consultations: 180, children: 28, vaccinations: 125 },
  { month: "Jul", mothers: 68, consultations: 175, children: 32, vaccinations: 118 },
  { month: "Aoû", mothers: 58, consultations: 160, children: 24, vaccinations: 105 },
  { month: "Sep", mothers: 75, consultations: 195, children: 30, vaccinations: 135 },
  { month: "Oct", mothers: 82, consultations: 210, children: 35, vaccinations: 145 },
  { month: "Nov", mothers: 90, consultations: 225, children: 40, vaccinations: 160 },
];

const centerStats = [
  { name: "Grand-Yoff", mothers: 156, consultations: 420, children: 85, growth: 12 },
  { name: "Parcelles", mothers: 134, consultations: 380, children: 72, growth: 8 },
  { name: "Thiès", mothers: 98, consultations: 290, children: 55, growth: 15 },
  { name: "Saint-Louis", mothers: 87, consultations: 250, children: 48, growth: -3 },
  { name: "Kaolack", mothers: 76, consultations: 220, children: 42, growth: 5 },
];

const distributionData = [
  { name: "Dakar", value: 45, color: "#10b981" },
  { name: "Thiès", value: 20, color: "#3b82f6" },
  { name: "Saint-Louis", value: 15, color: "#8b5cf6" },
  { name: "Kaolack", value: 12, color: "#f59e0b" },
  { name: "Autres", value: 8, color: "#6b7280" },
];

const genderData = [
  { name: "Filles", value: 156, color: "#ec4899" },
  { name: "Garçons", value: 142, color: "#3b82f6" },
];

const genderByMonth = [
  { month: "Jan", filles: 12, garcons: 10 },
  { month: "Fév", filles: 14, garcons: 12 },
  { month: "Mar", filles: 11, garcons: 15 },
  { month: "Avr", filles: 16, garcons: 14 },
  { month: "Mai", filles: 13, garcons: 11 },
  { month: "Jun", filles: 18, garcons: 16 },
  { month: "Jul", filles: 15, garcons: 19 },
  { month: "Aoû", filles: 14, garcons: 12 },
  { month: "Sep", filles: 17, garcons: 15 },
  { month: "Oct", filles: 12, garcons: 10 },
  { month: "Nov", filles: 14, garcons: 8 },
];

const weeklyData = [
  { day: "Lun", cpn: 28, vaccinations: 15 },
  { day: "Mar", cpn: 35, vaccinations: 22 },
  { day: "Mer", cpn: 42, vaccinations: 18 },
  { day: "Jeu", cpn: 38, vaccinations: 25 },
  { day: "Ven", cpn: 45, vaccinations: 30 },
  { day: "Sam", cpn: 20, vaccinations: 12 },
  { day: "Dim", cpn: 8, vaccinations: 5 },
];

const recentActivity = [
  { type: "mother", message: "Nouvelle mère inscrite à Grand-Yoff", time: "Il y a 5 min" },
  { type: "consultation", message: "CPN effectuée à Parcelles", time: "Il y a 15 min" },
  { type: "card", message: "Carte QR validée à Thiès", time: "Il y a 30 min" },
  { type: "mother", message: "Nouvelle mère inscrite à Saint-Louis", time: "Il y a 1h" },
  { type: "child", message: "Nouvel enfant enregistré à Kaolack", time: "Il y a 2h" },
];

const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    return (
      <div className="bg-card border border-border rounded-xl p-3 shadow-xl">
        <p className="font-semibold text-foreground mb-2">{label}</p>
        {payload.map((entry: any, index: number) => (
          <p key={index} className="text-sm" style={{ color: entry.color }}>
            {entry.name}: <span className="font-bold">{entry.value}</span>
          </p>
        ))}
      </div>
    );
  }
  return null;
};

const Statistics = () => {
  const [period, setPeriod] = useState("year");

  // Calculs des totaux
  const totalMothers = monthlyData.reduce((sum, m) => sum + m.mothers, 0);
  const totalConsultations = monthlyData.reduce((sum, m) => sum + m.consultations, 0);
  const totalChildren = monthlyData.reduce((sum, m) => sum + m.children, 0);
  const totalVaccinations = monthlyData.reduce((sum, m) => sum + m.vaccinations, 0);

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="max-w-7xl mx-auto p-6">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8 animate-slide-up">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Sparkles className="w-5 h-5 text-primary" />
              <span className="text-sm font-medium text-primary">Analyses & Rapports</span>
            </div>
            <h1 className="text-3xl font-bold text-foreground">Statistiques</h1>
            <p className="text-muted-foreground mt-1">
              Vue d'ensemble des performances du système de santé
            </p>
          </div>
          <div className="flex gap-3">
            <Select value={period} onValueChange={setPeriod}>
              <SelectTrigger className="w-[180px] h-11 rounded-xl">
                <Calendar className="w-4 h-4 mr-2 text-muted-foreground" />
                <SelectValue />
              </SelectTrigger>
              <SelectContent className="rounded-xl">
                <SelectItem value="week">Cette semaine</SelectItem>
                <SelectItem value="month">Ce mois</SelectItem>
                <SelectItem value="quarter">Ce trimestre</SelectItem>
                <SelectItem value="year">Cette année</SelectItem>
              </SelectContent>
            </Select>
            <Button variant="outline" className="h-11 rounded-xl">
              <Download className="w-4 h-4 mr-2" />
              Exporter
            </Button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div className="animate-slide-up delay-100">
            <StatCard
              icon={Users}
              title="Mères inscrites"
              value={totalMothers}
              subtitle="Cette année"
              trend={12}
              color="green"
            />
          </div>
          <div className="animate-slide-up delay-200">
            <StatCard
              icon={ClipboardCheck}
              title="Consultations CPN"
              value={totalConsultations}
              subtitle="Effectuées"
              trend={8}
              color="blue"
            />
          </div>
          <div className="animate-slide-up delay-300">
            <StatCard
              icon={Baby}
              title="Enfants suivis"
              value={totalChildren}
              subtitle="De 0 à 18 ans"
              trend={15}
              color="purple"
            />
          </div>
          <div className="animate-slide-up delay-400">
            <StatCard
              icon={Syringe}
              title="Vaccinations"
              value={totalVaccinations}
              subtitle="Administrées"
              trend={10}
              color="orange"
            />
          </div>
        </div>

        {/* Main Charts Row */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* Evolution Chart */}
          <div className="lg:col-span-2 bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-200">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-bold flex items-center gap-2">
                  <TrendingUp className="w-5 h-5 text-primary" />
                  Évolution mensuelle
                </h2>
                <p className="text-sm text-muted-foreground">
                  Inscriptions et consultations au cours de l'année
                </p>
              </div>
              <div className="flex items-center gap-4 text-sm">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-emerald-500"></div>
                  <span className="text-muted-foreground">Mères</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-blue-500"></div>
                  <span className="text-muted-foreground">CPN</span>
                </div>
              </div>
            </div>

            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={monthlyData}>
                  <defs>
                    <linearGradient id="colorMothers" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#10b981" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#10b981" stopOpacity={0}/>
                    </linearGradient>
                    <linearGradient id="colorConsultations" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis 
                    dataKey="month" 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <YAxis 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <Tooltip content={<CustomTooltip />} />
                  <Area 
                    type="monotone" 
                    dataKey="mothers" 
                    stroke="#10b981" 
                    strokeWidth={3}
                    fillOpacity={1} 
                    fill="url(#colorMothers)"
                    name="Mères"
                  />
                  <Area 
                    type="monotone" 
                    dataKey="consultations" 
                    stroke="#3b82f6" 
                    strokeWidth={3}
                    fillOpacity={1} 
                    fill="url(#colorConsultations)"
                    name="Consultations"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Distribution Pie Chart */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-300">
            <div className="mb-6">
              <h2 className="text-lg font-bold flex items-center gap-2">
                <Building2 className="w-5 h-5 text-primary" />
                Répartition géographique
              </h2>
              <p className="text-sm text-muted-foreground">
                Distribution des mères par région
              </p>
            </div>

            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={distributionData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={4}
                    dataKey="value"
                  >
                    {distributionData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>

            <div className="grid grid-cols-2 gap-2 mt-4">
              {distributionData.map((item, index) => (
                <div key={index} className="flex items-center gap-2 text-sm">
                  <div 
                    className="w-3 h-3 rounded-full" 
                    style={{ backgroundColor: item.color }}
                  />
                  <span className="text-muted-foreground">{item.name}</span>
                  <span className="font-semibold ml-auto">{item.value}%</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Gender Statistics Row */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
          {/* Gender Pie Chart */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-300">
            <div className="mb-6">
              <h2 className="text-lg font-bold flex items-center gap-2">
                <Baby className="w-5 h-5 text-primary" />
                Répartition par sexe
              </h2>
              <p className="text-sm text-muted-foreground">
                Naissances enregistrées
              </p>
            </div>

            <div className="h-48">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={genderData}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={75}
                    paddingAngle={4}
                    dataKey="value"
                  >
                    {genderData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>

            <div className="flex justify-center gap-8 mt-4">
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-pink-500" />
                <div>
                  <p className="text-2xl font-bold text-pink-500">156</p>
                  <p className="text-xs text-muted-foreground">Filles</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-blue-500" />
                <div>
                  <p className="text-2xl font-bold text-blue-500">142</p>
                  <p className="text-xs text-muted-foreground">Garçons</p>
                </div>
              </div>
            </div>
          </div>

          {/* Gender Bar Chart by Month */}
          <div className="lg:col-span-2 bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-400">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-bold flex items-center gap-2">
                  <Heart className="w-5 h-5 text-rose-500" />
                  Naissances par mois
                </h2>
                <p className="text-sm text-muted-foreground">
                  Comparaison filles vs garçons
                </p>
              </div>
              <div className="flex items-center gap-4 text-sm">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-pink-500"></div>
                  <span className="text-muted-foreground">Filles</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-blue-500"></div>
                  <span className="text-muted-foreground">Garçons</span>
                </div>
              </div>
            </div>

            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={genderByMonth} barGap={4}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis 
                    dataKey="month" 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <YAxis 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <Tooltip content={<CustomTooltip />} />
                  <Bar 
                    dataKey="filles" 
                    fill="#ec4899" 
                    radius={[4, 4, 0, 0]}
                    name="Filles"
                  />
                  <Bar 
                    dataKey="garcons" 
                    fill="#3b82f6" 
                    radius={[4, 4, 0, 0]}
                    name="Garçons"
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Second Row */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Weekly Activity */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-300">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-bold flex items-center gap-2">
                  <Activity className="w-5 h-5 text-primary" />
                  Activité hebdomadaire
                </h2>
                <p className="text-sm text-muted-foreground">
                  CPN et vaccinations cette semaine
                </p>
              </div>
            </div>

            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={weeklyData} barGap={8}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis 
                    dataKey="day" 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <YAxis 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <Tooltip content={<CustomTooltip />} />
                  <Bar 
                    dataKey="cpn" 
                    fill="#10b981" 
                    radius={[6, 6, 0, 0]}
                    name="CPN"
                  />
                  <Bar 
                    dataKey="vaccinations" 
                    fill="#8b5cf6" 
                    radius={[6, 6, 0, 0]}
                    name="Vaccinations"
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Center Performance */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-400">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-bold flex items-center gap-2">
                  <BarChart3 className="w-5 h-5 text-primary" />
                  Performance par centre
                </h2>
                <p className="text-sm text-muted-foreground">
                  Top 5 des centres de santé
                </p>
              </div>
            </div>

            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={centerStats} layout="vertical" barSize={20}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" horizontal={false} />
                  <XAxis 
                    type="number"
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <YAxis 
                    type="category"
                    dataKey="name"
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                    width={80}
                  />
                  <Tooltip content={<CustomTooltip />} />
                  <Bar 
                    dataKey="mothers" 
                    fill="#10b981" 
                    radius={[0, 6, 6, 0]}
                    name="Mères"
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Trend Line + Activity */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Trend Chart */}
          <div className="lg:col-span-2 bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-400">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-bold flex items-center gap-2">
                  <Heart className="w-5 h-5 text-rose-500" />
                  Tendances
                </h2>
                <p className="text-sm text-muted-foreground">
                  Comparaison mères, enfants et vaccinations
                </p>
              </div>
            </div>

            <div className="h-72">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis 
                    dataKey="month" 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <YAxis 
                    stroke="hsl(var(--muted-foreground))"
                    fontSize={12}
                    tickLine={false}
                    axisLine={false}
                  />
                  <Tooltip content={<CustomTooltip />} />
                  <Legend />
                  <Line 
                    type="monotone" 
                    dataKey="mothers" 
                    stroke="#10b981" 
                    strokeWidth={3}
                    dot={{ fill: "#10b981", strokeWidth: 2, r: 4 }}
                    activeDot={{ r: 6 }}
                    name="Mères"
                  />
                  <Line 
                    type="monotone" 
                    dataKey="children" 
                    stroke="#8b5cf6" 
                    strokeWidth={3}
                    dot={{ fill: "#8b5cf6", strokeWidth: 2, r: 4 }}
                    activeDot={{ r: 6 }}
                    name="Enfants"
                  />
                  <Line 
                    type="monotone" 
                    dataKey="vaccinations" 
                    stroke="#f59e0b" 
                    strokeWidth={3}
                    dot={{ fill: "#f59e0b", strokeWidth: 2, r: 4 }}
                    activeDot={{ r: 6 }}
                    name="Vaccinations"
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Recent Activity */}
          <div className="bg-card rounded-2xl border border-border/50 p-6 animate-slide-up delay-500">
            <h2 className="text-lg font-bold mb-6 flex items-center gap-2">
              <Activity className="w-5 h-5 text-primary" />
              Activité récente
            </h2>
            <div className="space-y-4">
              {recentActivity.map((activity, index) => (
                <div 
                  key={index} 
                  className="flex items-start gap-3 p-3 rounded-xl hover:bg-muted/50 transition-colors"
                >
                  <div
                    className={`p-2 rounded-xl ${
                      activity.type === "mother"
                        ? "bg-emerald-500/10"
                        : activity.type === "consultation"
                        ? "bg-blue-500/10"
                        : activity.type === "child"
                        ? "bg-purple-500/10"
                        : "bg-amber-500/10"
                    }`}
                  >
                    {activity.type === "mother" && <Users className="w-4 h-4 text-emerald-600" />}
                    {activity.type === "consultation" && (
                      <ClipboardCheck className="w-4 h-4 text-blue-600" />
                    )}
                    {activity.type === "child" && <Baby className="w-4 h-4 text-purple-600" />}
                    {activity.type === "card" && <TrendingUp className="w-4 h-4 text-amber-600" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-foreground truncate">{activity.message}</p>
                    <p className="text-xs text-muted-foreground">{activity.time}</p>
                  </div>
                </div>
              ))}
            </div>
            <Button variant="outline" className="w-full mt-4 rounded-xl">
              Voir toute l'activité
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Statistics;
