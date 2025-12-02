import { LucideIcon } from "lucide-react";
import { TrendingUp } from "lucide-react";

interface StatCardProps {
  icon: LucideIcon;
  title: string;
  value: number;
  subtitle: string;
  trend?: number;
  color?: "green" | "blue" | "purple" | "orange" | "rose";
  className?: string;
}

const colorVariants = {
  green: {
    bg: "bg-gradient-to-br from-emerald-500 to-green-600",
    light: "bg-emerald-50 dark:bg-emerald-950/30",
    text: "text-emerald-600 dark:text-emerald-400",
    border: "border-emerald-200 dark:border-emerald-800",
    glow: "shadow-emerald-500/20",
  },
  blue: {
    bg: "bg-gradient-to-br from-blue-500 to-indigo-600",
    light: "bg-blue-50 dark:bg-blue-950/30",
    text: "text-blue-600 dark:text-blue-400",
    border: "border-blue-200 dark:border-blue-800",
    glow: "shadow-blue-500/20",
  },
  purple: {
    bg: "bg-gradient-to-br from-purple-500 to-violet-600",
    light: "bg-purple-50 dark:bg-purple-950/30",
    text: "text-purple-600 dark:text-purple-400",
    border: "border-purple-200 dark:border-purple-800",
    glow: "shadow-purple-500/20",
  },
  orange: {
    bg: "bg-gradient-to-br from-orange-500 to-amber-600",
    light: "bg-orange-50 dark:bg-orange-950/30",
    text: "text-orange-600 dark:text-orange-400",
    border: "border-orange-200 dark:border-orange-800",
    glow: "shadow-orange-500/20",
  },
  rose: {
    bg: "bg-gradient-to-br from-rose-500 to-pink-600",
    light: "bg-rose-50 dark:bg-rose-950/30",
    text: "text-rose-600 dark:text-rose-400",
    border: "border-rose-200 dark:border-rose-800",
    glow: "shadow-rose-500/20",
  },
};

const StatCard = ({ 
  icon: Icon, 
  title, 
  value, 
  subtitle, 
  trend,
  color = "green",
  className = "" 
}: StatCardProps) => {
  const colors = colorVariants[color];
  
  return (
    <div className={`
      relative overflow-hidden rounded-2xl p-6 
      bg-card border ${colors.border}
      card-hover group
      ${className}
    `}>
      {/* Background decoration */}
      <div className={`absolute -right-8 -top-8 w-32 h-32 rounded-full ${colors.light} opacity-50 group-hover:scale-150 transition-transform duration-500`} />
      <div className={`absolute -right-4 -top-4 w-24 h-24 rounded-full ${colors.light} opacity-30 group-hover:scale-125 transition-transform duration-700`} />
      
      <div className="relative flex items-start gap-4">
        {/* Icon */}
        <div className={`
          w-14 h-14 rounded-2xl ${colors.bg} 
          flex items-center justify-center 
          shadow-lg ${colors.glow}
          group-hover:scale-110 transition-transform duration-300
        `}>
          <Icon className="w-7 h-7 text-white" />
        </div>
        
        {/* Content */}
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium text-muted-foreground mb-1 truncate">
            {title}
          </p>
          <div className="flex items-baseline gap-2">
            <span className="text-3xl font-bold text-foreground">
              {value.toLocaleString()}
            </span>
            {trend !== undefined && (
              <span className={`flex items-center text-sm font-medium ${trend >= 0 ? 'text-emerald-500' : 'text-rose-500'}`}>
                <TrendingUp className={`w-4 h-4 mr-0.5 ${trend < 0 ? 'rotate-180' : ''}`} />
                {Math.abs(trend)}%
              </span>
            )}
          </div>
          <p className="text-xs text-muted-foreground mt-1">
            {subtitle}
          </p>
        </div>
      </div>
    </div>
  );
};

export default StatCard;
