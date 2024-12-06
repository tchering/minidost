#! -->3 app/factories/task_pdf_decorator_factory.rb
class TaskPdfDecoratorFactory
  def self.create(task)
    case task.taskable_type
    when "PeintreTask"
      PeintreTaskPdfDecorator.new(task)
    when "ElectricienTask"
      ElectricienTaskPdfDecorator.new(task)
    else
      TaskPdfDecorator.new(task)
    end
  end
end
