require 'memory_profiler'
require 'destructure'

describe 'Performance' do
  it 'is efficient' do
    a = [1, 2, 3, 4]
    match_once(a)
    report = MemoryProfiler.report do
      100.times do
        match_once(a)
      end
    end

    report.pretty_print
  end

  it 'is fast' do
    a = [1, 2, 3, 4]
    50_000.times.each { |i| match_once(a) } # should take a fraction of a second
  end

  def match_once(a)
    destructure(a) do
      if match { [1, x, y, 4] }
      else
        raise "didn't match"
      end
    end
  end
end
