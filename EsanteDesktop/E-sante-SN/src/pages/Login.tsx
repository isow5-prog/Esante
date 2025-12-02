import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Shield, Eye, EyeOff, Sparkles, Heart, Baby, Users } from "lucide-react";
import Logo from "@/components/Logo";

const Login = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    // Simulate loading
    await new Promise(resolve => setTimeout(resolve, 800));
    navigate("/dashboard");
  };

  return (
    <div className="min-h-screen flex">
      {/* Left Side - Decorative */}
      <div className="hidden lg:flex lg:w-1/2 gradient-hero relative overflow-hidden">
        {/* Background patterns */}
        <div className="absolute inset-0 pattern-dots opacity-30" />
        
        {/* Floating circles */}
        <div className="absolute top-20 left-20 w-72 h-72 bg-white/10 rounded-full blur-3xl animate-float" />
        <div className="absolute bottom-20 right-20 w-96 h-96 bg-emerald-300/10 rounded-full blur-3xl animate-float delay-300" />
        <div className="absolute top-1/2 left-1/3 w-48 h-48 bg-white/5 rounded-full blur-2xl animate-pulse-slow" />

        {/* Content */}
        <div className="relative z-10 flex flex-col justify-center px-16 text-white">
          <div className="animate-slide-up">
            <div className="flex items-center gap-3 mb-8">
              <div className="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur-xl flex items-center justify-center">
                <Shield className="w-8 h-8" />
              </div>
              <div>
                <h1 className="text-4xl font-bold">E-Santé SN</h1>
                <p className="text-white/80">Carnet de Santé Digital</p>
              </div>
            </div>

            <h2 className="text-3xl font-semibold mb-6 leading-tight">
              La santé maternelle et <br/>
              infantile au cœur du <br/>
              <span className="text-emerald-200">numérique</span>
            </h2>

            <p className="text-white/70 text-lg mb-12 max-w-md">
              Une plateforme innovante pour le suivi des femmes enceintes 
              et des enfants au Sénégal.
            </p>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-6">
              <div className="animate-slide-up delay-100">
                <div className="glass-dark rounded-2xl p-4 text-center">
                  <Users className="w-8 h-8 mx-auto mb-2 text-emerald-200" />
                  <div className="text-2xl font-bold">1,500+</div>
                  <div className="text-sm text-white/60">Mères inscrites</div>
                </div>
              </div>
              <div className="animate-slide-up delay-200">
                <div className="glass-dark rounded-2xl p-4 text-center">
                  <Heart className="w-8 h-8 mx-auto mb-2 text-rose-300" />
                  <div className="text-2xl font-bold">3,200+</div>
                  <div className="text-sm text-white/60">Consultations</div>
                </div>
              </div>
              <div className="animate-slide-up delay-300">
                <div className="glass-dark rounded-2xl p-4 text-center">
                  <Baby className="w-8 h-8 mx-auto mb-2 text-amber-200" />
                  <div className="text-2xl font-bold">800+</div>
                  <div className="text-sm text-white/60">Enfants suivis</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom wave */}
        <div className="absolute bottom-0 left-0 right-0">
          <svg viewBox="0 0 1440 120" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0 120L60 105C120 90 240 60 360 45C480 30 600 30 720 37.5C840 45 960 60 1080 67.5C1200 75 1320 75 1380 75L1440 75V120H1380C1320 120 1200 120 1080 120C960 120 840 120 720 120C600 120 480 120 360 120C240 120 120 120 60 120H0Z" fill="white" fillOpacity="0.1"/>
          </svg>
        </div>
      </div>

      {/* Right Side - Login Form */}
      <div className="flex-1 flex items-center justify-center p-8 bg-gradient-to-br from-background via-background to-muted/30">
        <div className="w-full max-w-md animate-scale-in">
          {/* Mobile Logo */}
          <div className="lg:hidden flex justify-center mb-8">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-xl gradient-primary flex items-center justify-center">
                <Shield className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gradient">E-Santé SN</h1>
              </div>
            </div>
          </div>

          {/* Login Card */}
          <div className="bg-card rounded-3xl border border-border/50 p-8 shadow-xl shadow-primary/5">
            <div className="flex justify-center mb-6">
              <div className="w-20 h-20 rounded-2xl gradient-primary flex items-center justify-center shadow-lg shadow-primary/30 animate-bounce-in">
                <Logo />
              </div>
            </div>
            
            <div className="text-center mb-8">
              <h1 className="text-2xl font-bold mb-2">Bienvenue !</h1>
              <p className="text-muted-foreground">
                Connectez-vous à votre espace professionnel
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-5">
              <div className="space-y-2 animate-slide-up delay-100">
                <Label htmlFor="email" className="text-sm font-medium">
                  Identifiant Badge
                </Label>
                <div className="relative">
                  <Input
                    id="email"
                    type="text"
                    placeholder="Ex: AGENT-001 ou MIN-001"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="h-12 pl-4 pr-4 rounded-xl bg-muted/50 border-border/50 input-focus"
                  />
                </div>
              </div>

              <div className="space-y-2 animate-slide-up delay-200">
                <Label htmlFor="password" className="text-sm font-medium">
                  Mot de passe
                </Label>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    placeholder="••••••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    className="h-12 pl-4 pr-12 rounded-xl bg-muted/50 border-border/50 input-focus"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between text-sm animate-slide-up delay-300">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" className="rounded border-border" />
                  <span className="text-muted-foreground">Se souvenir de moi</span>
                </label>
                <a href="#" className="text-primary hover:underline font-medium">
                  Mot de passe oublié ?
                </a>
              </div>

              <Button 
                type="submit" 
                className="w-full h-12 rounded-xl text-base font-semibold gradient-primary hover:opacity-90 transition-all duration-300 shadow-lg shadow-primary/25 btn-glow animate-slide-up delay-400"
                disabled={isLoading}
              >
                {isLoading ? (
                  <div className="flex items-center gap-2">
                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Connexion...
                  </div>
                ) : (
                  <div className="flex items-center gap-2">
                    <Sparkles className="w-5 h-5" />
                    Se connecter
                  </div>
                )}
              </Button>
            </form>

            {/* Footer */}
            <div className="mt-8 pt-6 border-t border-border/50 text-center">
              <p className="text-sm text-muted-foreground">
                Système de santé du{" "}
                <span className="font-semibold text-foreground">Ministère de la Santé</span>
              </p>
              <p className="text-xs text-muted-foreground mt-2">
                🇸🇳 République du Sénégal
              </p>
            </div>
          </div>

          {/* Help text */}
          <p className="text-center text-sm text-muted-foreground mt-6 animate-fade-in delay-500">
            Besoin d'aide ? Contactez le support technique
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
