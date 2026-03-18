module ClassSchedulesHelper
  def modality_badge(schedule)
    return unless schedule.show_modality?

    config = case schedule.modality
             when "gi"
               # Azul cobalto fuerte con texto blanco
               { label: "GI", css: "bg-indigo-600 text-white border-indigo-700 shadow-sm" }
             when "nogi"
               # Negro/Zinc muy oscuro con texto blanco
               { label: "NO-GI", css: "bg-zinc-900 text-white border-zinc-950 shadow-sm" }
             else
               { label: schedule.modality.upcase, css: "bg-slate-700 text-white border-slate-800" }
             end

    content_tag :span, config[:label], 
    class: "inline-flex items-center px-2 py-0.5 rounded-md text-[9px] font-black border uppercase tracking-widest leading-none #{config[:css]}"
  end
end
