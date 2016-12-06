defmodule Exrbbench do
  use Application
  use Export.Ruby

  @ruby_dir Application.app_dir(:exrbbench, "priv/ruby")
  @erlectricity_command "ruby #{@ruby_dir}/erlectricity.rb"

  def sum_two_integers(one, other) do
    one + other
  end

  def sum_two_integers_process do
    receive do
      {:sum, one, other, pid} -> send pid, {:result, one + other}
      _ -> nil
    end
    sum_two_integers_process
  end

  def sum_two_integers_in_process(pid, one, other) do
    send pid, {:sum, one, other, self()}
    receive do
      {:result, result} -> result
    end
  end

  def sum_two_integers_in_ruby_with_export(ruby, one, other) do
    ruby
    |> Ruby.call(sum_two_integers(one, other), from_file: "export")
  end

  def sum_two_integers_in_ruby_with_erlectricity(pid, one, another) do
    Port.connect(pid, self())
    encoded_msg = {:sum_two_integers, one, another}  |> :erlang.term_to_binary
    pid |> Port.command(encoded_msg)

    receive do
      {^pid, {:data, data}} ->
        case data |> :erlang.binary_to_term do
          {:result, result} -> result
          _ -> nil
        end
    end
  end

  def wait_for_erlix_pid do
    IO.inspect "wait for ruby node..."

    Process.register(self(), :ex_rb)
    receive do
      {:register, pid} -> pid
    end
  end

  def sum_two_integers_in_ruby_with_erlix(pid, one, other) do
    unless Process.registered |> Enum.member?(:ex_rb_b) do
      Process.register(self(), :ex_rb_b)
    end
    send pid, {self(), one, other}
    receive do
      {data} -> data
      e -> IO.inspect(e)
    end
  end

  def start(_type, _args) do
    IO.inspect "Start!"

    elixir_process_pid = spawn fn -> sum_two_integers_process end
    {:ok, export_process_pid} = Ruby.start(ruby_lib: @ruby_dir)
    erlectricity_process_pid = Port.open({:spawn, @erlectricity_command}, [{:packet, 4}, :nouse_stdio, :exit_status, :binary])

    # erlix_process_pid = wait_for_erlix_pid

    Benchee.run(%{
      # "local_function" => fn -> sum_two_integers(1, 2) end,
      "process_function" => fn -> sum_two_integers_in_process(elixir_process_pid, 1, 2) end,
      "export_function" => fn -> sum_two_integers_in_ruby_with_export(export_process_pid, 1, 2) end,
      "erlectricity_function" => fn -> sum_two_integers_in_ruby_with_erlectricity(erlectricity_process_pid, 1,2) end,
      # "erlix_function" => fn -> sum_two_integers_in_ruby_with_erlix(erlix_process_pid, 1,2) end,
    })

    {:ok, self()}
  end
end
