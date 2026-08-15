# カレントディレクトリをボタンで表示する簡易GUIランチャー。
# xonshで `files-gui` を実行すると開く。
def _current_files_gui(args=None, stdin=None, stdout=None, stderr=None):
    import os
    import tkinter as tk
    from tkinter import messagebox
    from pathlib import Path

    current_dir = Path.cwd()

    root = tk.Tk()
    root.title(f"Files - {current_dir}")
    root.geometry("760x560")
    root.minsize(420, 300)
    root.attributes("-topmost", True)
    root.after_idle(root.lift)

    toolbar = tk.Frame(root, padx=8, pady=8)
    toolbar.pack(fill="x")

    path_label = tk.Label(
        toolbar,
        text=str(current_dir),
        anchor="w",
        justify="left",
    )
    path_label.pack(side="left", fill="x", expand=True)

    canvas = tk.Canvas(root, highlightthickness=0)
    scrollbar = tk.Scrollbar(root, orient="vertical", command=canvas.yview)
    button_frame = tk.Frame(canvas, padx=8, pady=8)
    frame_window = canvas.create_window((0, 0), window=button_frame, anchor="nw")

    canvas.configure(yscrollcommand=scrollbar.set)
    scrollbar.pack(side="right", fill="y")
    canvas.pack(side="left", fill="both", expand=True)

    def open_path(path):
        try:
            # Windowsの関連付けを使い、ファイルは既定アプリ、
            # フォルダはExplorerで開く。
            os.startfile(str(path))
        except OSError as exc:
            messagebox.showerror("開けませんでした", f"{path}\n\n{exc}")

    def refresh():
        for widget in button_frame.winfo_children():
            widget.destroy()

        try:
            entries = sorted(
                current_dir.iterdir(),
                key=lambda item: (not item.is_dir(), item.name.casefold()),
            )
        except OSError as exc:
            messagebox.showerror("一覧を取得できません", str(exc))
            return

        if not entries:
            tk.Label(button_frame, text="このフォルダは空です").grid(
                row=0, column=0, padx=6, pady=6, sticky="w"
            )
            return

        columns = 4
        for index, path in enumerate(entries):
            prefix = "📁 " if path.is_dir() else "📄 "
            button = tk.Button(
                button_frame,
                text=prefix + path.name,
                command=lambda selected=path: open_path(selected),
                anchor="w",
                justify="left",
                padx=8,
                pady=7,
                wraplength=160,
            )
            button.grid(
                row=index // columns,
                column=index % columns,
                padx=5,
                pady=5,
                sticky="nsew",
            )

        for column in range(columns):
            button_frame.grid_columnconfigure(column, weight=1, uniform="files")

        root.after_idle(
            lambda: canvas.configure(scrollregion=canvas.bbox("all"))
        )

    def resize_frame(event):
        canvas.itemconfigure(frame_window, width=event.width)

    def scroll(event):
        canvas.yview_scroll(int(-event.delta / 120), "units")

    tk.Button(toolbar, text="更新", command=refresh).pack(side="right", padx=(8, 0))
    canvas.bind("<Configure>", resize_frame)
    canvas.bind_all("<MouseWheel>", scroll)
    button_frame.bind(
        "<Configure>",
        lambda _event: canvas.configure(scrollregion=canvas.bbox("all")),
    )

    refresh()
    root.mainloop()


aliases["files-gui"] = _current_files_gui
