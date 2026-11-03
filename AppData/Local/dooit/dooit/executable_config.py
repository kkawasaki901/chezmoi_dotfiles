"""Personal Dooit configuration.

Task conventions:
- Workspaces are areas/projects (Inbox, Work, Personal, Someday, Archive).
- Nested todos are subtasks.
- Put tags such as @work, @home, @waiting in the description.
- Urgency: 1=low, 2=normal, 3=high, 4=critical.
- Effort is an integer estimate (use minutes or pomodoros consistently).
"""

from datetime import datetime, timedelta
import getpass

from rich.style import Style
from rich.text import Text

from dooit.api import Todo
from dooit.api.theme import DooitThemeBase
from dooit.ui.api import DooitAPI, subscribe, timer
from dooit.ui.api.events import ModeChanged, Startup
from dooit.ui.api.widgets import TodoWidget, WorkspaceWidget
from dooit.ui.widgets.bars import StatusBarWidget
from dooit.ui.widgets.inputs.model_inputs import Recurrence


class TaskTheme(DooitThemeBase):
    """High-contrast Catppuccin-inspired dark theme."""

    _name = "task-manager"
    background1 = "#11111b"
    background2 = "#181825"
    background3 = "#313244"
    foreground1 = "#cdd6f4"
    foreground2 = "#bac2de"
    foreground3 = "#f5e0dc"
    red = "#f38ba8"
    orange = "#fab387"
    yellow = "#f9e2af"
    green = "#a6e3a1"
    blue = "#89b4fa"
    purple = "#cba6f7"
    magenta = "#f5c2e7"
    cyan = "#94e2d5"
    primary = blue
    secondary = purple


def _current_todo(api: DooitAPI):
    todo = api.vars.current_todo
    if todo is None:
        api.notify("Select a task first", "warning")
    return todo


def _refresh_todos(api: DooitAPI):
    tree = api.vars.todos_tree
    if tree is not None:
        tree.force_refresh()


def _set_due(api: DooitAPI, due, label: str):
    todo = _current_todo(api)
    if todo is None:
        return
    todo.due = due
    todo.save()
    _refresh_todos(api)
    api.notify(f"Due: {label}")


def due_today(api: DooitAPI):
    """Set due date to today"""
    now = datetime.now()
    _set_due(api, now.replace(hour=23, minute=59, second=0, microsecond=0), "today")


def due_tomorrow(api: DooitAPI):
    """Set due date to tomorrow"""
    due = datetime.now() + timedelta(days=1)
    _set_due(api, due.replace(hour=23, minute=59, second=0, microsecond=0), "tomorrow")


def due_next_week(api: DooitAPI):
    """Set due date to one week from today"""
    due = datetime.now() + timedelta(days=7)
    _set_due(api, due.replace(hour=23, minute=59, second=0, microsecond=0), "+1 week")


def clear_due(api: DooitAPI):
    """Clear due date"""
    _set_due(api, None, "none")


def _set_urgency(api: DooitAPI, urgency: int):
    todo = _current_todo(api)
    if todo is None:
        return
    todo.urgency = urgency
    todo.save()
    _refresh_todos(api)
    api.notify(f"Priority: {urgency}")


def priority_low(api: DooitAPI):
    """Set priority to low (1)"""
    _set_urgency(api, 1)


def priority_normal(api: DooitAPI):
    """Set priority to normal (2)"""
    _set_urgency(api, 2)


def priority_high(api: DooitAPI):
    """Set priority to high (3)"""
    _set_urgency(api, 3)


def priority_critical(api: DooitAPI):
    """Set priority to critical (4)"""
    _set_urgency(api, 4)


def _set_recurrence(api: DooitAPI, recurrence, label: str):
    todo = _current_todo(api)
    if todo is None:
        return
    todo.recurrence = recurrence
    todo.save()
    _refresh_todos(api)
    api.notify(f"Repeat: {label}")


def repeat_daily(api: DooitAPI):
    """Repeat every day"""
    _set_recurrence(api, timedelta(days=1), "daily")


def repeat_weekly(api: DooitAPI):
    """Repeat every week"""
    _set_recurrence(api, timedelta(weeks=1), "weekly")


def repeat_monthly(api: DooitAPI):
    """Repeat every 30 days"""
    _set_recurrence(api, timedelta(days=30), "every 30 days")


def clear_recurrence(api: DooitAPI):
    """Disable recurrence"""
    _set_recurrence(api, None, "none")


def todo_status_formatter(status: str, _todo: Todo, api: DooitAPI):
    theme = api.vars.theme
    symbols = {
        "completed": ("✓", theme.green),
        "overdue": ("!", theme.red),
        "pending": ("○", theme.yellow),
    }
    symbol, color = symbols.get(status, ("?", theme.foreground2))
    return Text(symbol, style=Style(color=color, bold=True))


def todo_due_formatter(due, todo: Todo, api: DooitAPI):
    if due is None:
        return ""
    theme = api.vars.theme
    now = datetime.now()
    if todo.is_overdue:
        color, prefix = theme.red, "OVERDUE "
    elif due.date() == now.date():
        color, prefix = theme.orange, "TODAY "
    elif due.date() == (now + timedelta(days=1)).date():
        color, prefix = theme.yellow, "TOMORROW "
    else:
        color, prefix = theme.blue, ""
    value = due.strftime("%Y-%m-%d")
    if due.hour or due.minute:
        value += due.strftime(" %H:%M")
    return Text(prefix + value, style=Style(color=color, bold=bool(prefix)))


def todo_urgency_formatter(urgency: int, _todo: Todo, api: DooitAPI):
    if not urgency:
        return ""
    theme = api.vars.theme
    labels = {
        1: ("P4 low", theme.green),
        2: ("P3 normal", theme.blue),
        3: ("P2 high", theme.orange),
        4: ("P1 critical", theme.red),
    }
    label, color = labels.get(urgency, (f"P? {urgency}", theme.foreground2))
    return Text(label, style=Style(color=color, bold=urgency >= 3))


def todo_effort_formatter(effort: int, _todo: Todo, api: DooitAPI):
    if not effort:
        return ""
    return Text(f"{effort}m", style=Style(color=api.vars.theme.cyan))


def todo_recurrence_formatter(recurrence, _todo: Todo, api: DooitAPI):
    if recurrence is None:
        return ""
    return Text(
        "↻" + Recurrence.timedelta_to_simple_string(recurrence),
        style=Style(color=api.vars.theme.purple),
    )


@subscribe(ModeChanged)
def mode_widget(api: DooitAPI, event: ModeChanged):
    theme = api.vars.theme
    color = theme.primary if event.mode == "NORMAL" else theme.secondary
    return Text(
        f" {event.mode} ",
        style=Style(color=theme.background1, bgcolor=color, bold=True),
    )


@timer(1)
def clock_widget(api: DooitAPI):
    return Text(
        datetime.now().strftime(" %Y-%m-%d %a %H:%M:%S "),
        style=Style(color=api.vars.theme.background1, bgcolor=api.vars.theme.secondary),
    )


@timer(5)
def stats_widget(api: DooitAPI):
    todos = Todo.all()
    pending = sum(todo.is_pending for todo in todos)
    overdue = sum(todo.is_overdue for todo in todos)
    today = sum(
        todo.is_pending and todo.due is not None and todo.due.date() == datetime.now().date()
        for todo in todos
    )
    color = api.vars.theme.red if overdue else api.vars.theme.green
    return Text(
        f" pending:{pending} today:{today} overdue:{overdue} ",
        style=Style(color=color, bold=bool(overdue)),
    )


@subscribe(Startup)
def configure(api: DooitAPI, _event: Startup):
    api.css.set_theme(TaskTheme)

    # Keep the hierarchy visible and expose every built-in task field.
    api.vars.always_expand_workspaces = True
    api.vars.always_expand_todos = True
    api.vars.show_confirm = True
    api.layouts.workspace_layout = [WorkspaceWidget.description]
    api.layouts.todo_layout = [
        TodoWidget.status,
        TodoWidget.description,
        TodoWidget.due,
        TodoWidget.urgency,
        TodoWidget.effort,
        TodoWidget.recurrence,
    ]

    api.formatter.todos.status.add(todo_status_formatter)
    api.formatter.todos.due.add(todo_due_formatter)
    api.formatter.todos.urgency.add(todo_urgency_formatter)
    api.formatter.todos.effort.add(todo_effort_formatter)
    api.formatter.todos.recurrence.add(todo_recurrence_formatter)

    # Core navigation and task editing.
    bindings = [
        ("<tab>", api.switch_focus, "Switch workspace/task pane", "Navigation"),
        ("j", api.move_down, "Move down", "Navigation"),
        ("k", api.move_up, "Move up", "Navigation"),
        ("gg", api.go_to_top, "Go to top", "Navigation"),
        ("G", api.go_to_bottom, "Go to bottom", "Navigation"),
        ("z", api.toggle_expand, "Expand/collapse", "Navigation"),
        ("Z", api.toggle_expand_parent, "Expand/collapse parent", "Navigation"),
        ("a", api.add_sibling, "Add task/workspace", "Create and edit"),
        ("A", api.add_child_node, "Add subtask/sub-workspace", "Create and edit"),
        ("i", api.edit_description, "Edit description and @tags", "Create and edit"),
        ("d", api.edit_due, "Edit due date", "Create and edit"),
        ("e", api.edit_effort, "Edit effort estimate", "Create and edit"),
        ("r", api.edit_recurrence, "Edit recurrence", "Create and edit"),
        ("c", api.toggle_complete, "Complete/reopen task", "Task state"),
        ("xx", api.remove_node, "Delete", "Task state"),
        ("J", api.shift_down, "Move item down", "Organize"),
        ("K", api.shift_up, "Move item up", "Organize"),
        ("Y", api.copy_model, "Copy task tree", "Organize"),
        ("p", api.paste_model_below, "Paste below", "Organize"),
        ("P", api.paste_model_above, "Paste above", "Organize"),
        ("/", api.start_search, "Search descriptions and @tags", "Find and sort"),
        ("<ctrl+s>", api.start_sort, "Sort siblings", "Find and sort"),
        ("?", api.show_help, "Show all keybindings", "Application"),
        ("<ctrl+q>", api.quit, "Quit", "Application"),
    ]
    for key, callback, description, group in bindings:
        api.keys.set(key, callback, description, group)

    # Quick scheduling: leader is t (time), p (priority), and R (repeat).
    api.keys.set("tt", lambda: due_today(api), "Due today", "Quick due dates")
    api.keys.set("tm", lambda: due_tomorrow(api), "Due tomorrow", "Quick due dates")
    api.keys.set("tw", lambda: due_next_week(api), "Due in one week", "Quick due dates")
    api.keys.set("tx", lambda: clear_due(api), "Clear due date", "Quick due dates")
    api.keys.set("p1", lambda: priority_critical(api), "Priority 1: critical", "Quick priority")
    api.keys.set("p2", lambda: priority_high(api), "Priority 2: high", "Quick priority")
    api.keys.set("p3", lambda: priority_normal(api), "Priority 3: normal", "Quick priority")
    api.keys.set("p4", lambda: priority_low(api), "Priority 4: low", "Quick priority")
    api.keys.set("Rd", lambda: repeat_daily(api), "Repeat daily", "Quick recurrence")
    api.keys.set("Rw", lambda: repeat_weekly(api), "Repeat weekly", "Quick recurrence")
    api.keys.set("Rm", lambda: repeat_monthly(api), "Repeat every 30 days", "Quick recurrence")
    api.keys.set("Rx", lambda: clear_recurrence(api), "Disable recurrence", "Quick recurrence")

    api.bar.set(
        [
            StatusBarWidget(mode_widget),
            StatusBarWidget(stats_widget),
            StatusBarWidget(lambda: f" {getpass.getuser()} "),
            StatusBarWidget(clock_widget),
        ]
    )

    api.dashboard.set(
        [
            "Dooit Task Manager",
            "",
            "Recommended workspaces: Inbox / Work / Personal / Someday / Archive",
            "Use @work @home @waiting @next in task descriptions for tags.",
            "",
            "a: add   A: subtask   i: edit   c: complete   /: search",
            "tt/tm/tw: today/tomorrow/week   p1..p4: priority",
            "Rd/Rw/Rm: daily/weekly/monthly   ?: full help",
        ]
    )
